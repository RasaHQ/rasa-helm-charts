"""Template tests for the preview event client secret. Run: python3 charts/studio/ci/preview-events-test.py"""

import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

import yaml

CHART = Path(__file__).resolve().parent.parent
LINT_VALUES = CHART / "ci" / "lint-values.yaml"
GENERATED = {"name": "studio-preview-events", "key": "STUDIO_EVENTS_CLIENT_SECRET"}
EXISTING = {"secretName": "my-secrets", "secretKey": "PREVIEW_SECRET"}
LICENSE_AND_OPENAI = [
    {"name": "RASA_LICENSE", "valueFrom": {"secretKeyRef": {"name": "studio-secrets", "key": "RASA_PRO_LICENSE_SECRET_KEY"}}},
    {"name": "OPENAI_API_KEY", "valueFrom": {"secretKeyRef": {"name": "studio-secrets", "key": "OPENAI_API_KEY_SECRET_KEY"}}},
]


def render(*set_json):
    args = ["helm", "template", "r", str(CHART), "-f", str(LINT_VALUES), "--kube-version", "1.37.0"]
    for item in set_json:
        args += ["--set-json", item]
    result = subprocess.run(args, capture_output=True, text=True)
    return result, [d for d in yaml.safe_load_all(result.stdout) if d] if result.returncode == 0 else []


def find(docs, kind, name):
    return next((d for d in docs if d["kind"] == kind and d["metadata"]["name"] == name), None)


def env(deployment):
    return {e["name"]: e for e in deployment["spec"]["template"]["spec"]["containers"][0]["env"]}


def secret_ref(entry):
    return entry["valueFrom"]["secretKeyRef"]


def test_generated_secret_on_install():
    result, docs = render()
    assert result.returncode == 0, result.stderr
    secret = find(docs, "Secret", "studio-preview-events")
    assert secret, "generated Secret missing"
    assert secret["metadata"]["annotations"]["helm.sh/resource-policy"] == "keep"
    encoded = secret["data"]["STUDIO_EVENTS_CLIENT_SECRET"]
    assert re.fullmatch(r"rsc_[A-Za-z0-9_-]{43}", base64.b64decode(encoded).decode())

    app = find(docs, "Deployment", "r-studio-app")
    assert secret_ref(env(app)["STUDIO_EVENTS_CLIENT_SECRET"]) == GENERATED
    annotations = app["spec"]["template"]["metadata"]["annotations"]
    assert annotations["checksum/preview-events-secret"] == hashlib.sha256(encoded.encode()).hexdigest()

    model_service = env(find(docs, "Deployment", "rasapro"))
    assert model_service["STUDIO_EVENTS_CLIENT_ID"]["value"] == "studio-preview"
    assert secret_ref(model_service["STUDIO_EVENTS_CLIENT_SECRET"]) == GENERATED


def test_each_install_generates_a_new_secret():
    values = [find(render()[1], "Secret", "studio-preview-events")["data"] for _ in range(2)]
    assert values[0] != values[1]


def test_existing_secret_replaces_generated_secret():
    override_env = LICENSE_AND_OPENAI + [
        {"name": "STUDIO_EVENTS_CLIENT_ID", "value": "studio-preview"},
        {"name": "STUDIO_EVENTS_CLIENT_SECRET", "valueFrom": {"secretKeyRef": {"name": "my-secrets", "key": "PREVIEW_SECRET"}}},
    ]
    result, docs = render(
        f"app.previewEventsSecret.existingSecret={json.dumps(EXISTING)}",
        f"rasa.overrideEnv={json.dumps(override_env)}",
    )
    assert result.returncode == 0, result.stderr
    assert not find(docs, "Secret", "studio-preview-events")
    expected = {"name": "my-secrets", "key": "PREVIEW_SECRET"}
    app = find(docs, "Deployment", "r-studio-app")
    assert secret_ref(env(app)["STUDIO_EVENTS_CLIENT_SECRET"]) == expected
    assert "checksum/preview-events-secret" not in app["spec"]["template"]["metadata"]["annotations"]
    assert secret_ref(env(find(docs, "Deployment", "rasapro"))["STUDIO_EVENTS_CLIENT_SECRET"]) == expected


def test_existing_secret_without_model_service_entry_fails():
    result, _ = render(f"app.previewEventsSecret.existingSecret={json.dumps(EXISTING)}")
    assert result.returncode != 0
    assert 'secretKeyRef name "my-secrets", key "PREVIEW_SECRET"' in result.stderr


def test_override_env_without_client_id_fails():
    result, _ = render(f"rasa.overrideEnv={json.dumps(LICENSE_AND_OPENAI)}")
    assert result.returncode != 0
    assert "STUDIO_EVENTS_CLIENT_ID" in result.stderr


def test_model_service_disabled_still_gives_app_the_secret():
    result, docs = render("rasa.enabled=false")
    assert result.returncode == 0, result.stderr
    assert find(docs, "Secret", "studio-preview-events")
    assert secret_ref(env(find(docs, "Deployment", "r-studio-app"))["STUDIO_EVENTS_CLIENT_SECRET"]) == GENERATED


if __name__ == "__main__":
    tests = [(name, fn) for name, fn in globals().items() if name.startswith("test_")]
    failed = 0
    for name, fn in tests:
        try:
            fn()
            print(f"PASS {name}")
        except AssertionError as error:
            failed += 1
            print(f"FAIL {name}: {error}")
    sys.exit(1 if failed else 0)
