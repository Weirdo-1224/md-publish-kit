import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class WindowsPowerShellCompatTest(unittest.TestCase):
    def test_powershell_scripts_parse_under_windows_powershell_51(self):
        scripts = [
            ROOT / "scripts" / "build.ps1",
            ROOT / "scripts" / "build_all.ps1",
            ROOT / "scripts" / "install.ps1",
        ]
        script_list = "@(" + ",".join("'" + str(path).replace("'", "''") + "'" for path in scripts) + ")"
        command = (
            "$ErrorActionPreference='Stop';"
            "$failed=$false;"
            f"foreach($p in {script_list}){{"
            "$tokens=$null;$errors=$null;"
            "[System.Management.Automation.Language.Parser]::ParseFile($p,[ref]$tokens,[ref]$errors)|Out-Null;"
            "if($errors){$failed=$true;Write-Host \"PARSE_FAILED $p\";"
            "$errors|ForEach-Object{Write-Host ($_.Message + ' @ ' + $_.Extent.StartLineNumber + ':' + $_.Extent.StartColumnNumber)}}"
            "};"
            "if($failed){exit 1}"
        )
        result = subprocess.run(
            ["powershell", "-NoProfile", "-Command", command],
            cwd=ROOT,
            encoding="utf-8",
            errors="replace",
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
