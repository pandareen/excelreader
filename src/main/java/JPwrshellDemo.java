import com.profesorfalken.jpowershell.PowerShell;
import com.profesorfalken.jpowershell.PowerShellResponse;

public class JPwrshellDemo {

    public static void main(String args[])
    {
        PowerShell powerShell = PowerShell.openSession();

        PowerShellResponse response = powerShell.executeCommand("scripts/getmailbox.ps1");

        System.out.println("Results:" + response.getCommandOutput());
    }
}
