use Zef;
use Zef::Shell;
use Zef::Shell::PowerShell;

class Zef::Shell::PowerShell::download is Zef::Shell::PowerShell does Fetcher does Messenger {
    method fetch-matcher($url) { $ = $url.lc.starts-with('http://' | 'https://') }

    method probe {
        state $powershell-webrequest-probe = !$*DISTRO.is-win ?? False !! try {
            CATCH {
                when X::Proc::Unsuccessful { return False }
                default { return False }
            }
            my $proc = zrun('powershell', '-Command', 'Get-Command', '-Name', 'Invoke-WebRequest', :out);
            my @out  = $proc.out.lines;
            $proc.out.close;
            $ = ?$proc;
        }
        ?$powershell-webrequest-probe;
    }

    method fetch($url, $save-as) {
        mkdir($save-as.IO.dirname) unless $save-as.IO.dirname.IO.e;
        my $proc = $.zrun(%?RESOURCES<scripts/win32http.ps1>, $url, $save-as);
        ?$proc ?? $save-as !! False;
    }
}
