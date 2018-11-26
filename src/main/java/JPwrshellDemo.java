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
        PowerShellResponse response = powerShell.executeScript("scripts/CreateExchangeSessionScript.ps1", "-Username 'admin@stringbase.in' -Password 'Seclore@12' -ConnectionUrl 'https://ps.outlook.com/powershell'");
        //response = powerShell.executeScript("scripts/GetDeletedMailboxList.ps1", "-StartTime 0 -EndTime 1542889441000 -OutputFile 'c:/users/sandesh/out.txt'");
        //response = powerShell.executeScript("scripts/GetUpdatedMailboxList.ps1", "-StartTime 0 -EndTime 1542889441000 -OutputFile 'c:/users/sandesh/out.txt'");
        if (response.isError() == true) {
            System.out.println("Hello");
        }
        System.out.println(powerShell.isLastCommandInError());
        System.out.println("Results:" + response.getCommandOutput());


        powerShell.close();
    }
}
