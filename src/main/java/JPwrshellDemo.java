import com.profesorfalken.jpowershell.PowerShell;
import com.profesorfalken.jpowershell.PowerShellResponse;

public class JPwrshellDemo {

    public static void main(String args[])
    {
        PowerShell powerShell = PowerShell.openSession();

        PowerShellResponse response = powerShell.executeScript("scripts/part1.ps1");
        System.out.println("Results:" + response.getCommandOutput());


        response = powerShell.executeScript("scripts/part2.ps1");
        System.out.println("Results:" + response.getCommandOutput());
        powerShell.close();
    }
}
