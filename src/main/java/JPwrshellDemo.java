import com.profesorfalken.jpowershell.PowerShell;
import com.profesorfalken.jpowershell.PowerShellResponse;

import java.util.HashMap;
import java.util.Map;

public class JPwrshellDemo {

    public static void main(String args[])
    {
        PowerShell powerShell = PowerShell.openSession();

        Map<String, String> myConfig = new HashMap<String, String>();
        myConfig.put("maxWait", "300000");
        powerShell.configuration(myConfig);
        PowerShellResponse response = powerShell.executeScript("scripts/part1.ps1", "$blah='asdasd'");
        System.out.println("Results:" + response.getCommandOutput());


        response = powerShell.executeScript("scripts/part2.ps1");
        System.out.println("Results:" + response.getCommandOutput());
        powerShell.close();
    }
}
