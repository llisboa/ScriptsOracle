
REM PERMISSÕES:::
REM             :R LER
REM             :W GRAVAR
REM             :C ALTERAR
REM             :F FULL
REM ________________________________________________________________________

cacls C:\Inetpub\wwwroot\INTERMESA /T /E /G "TODOS":R
cacls C:\Inetpub\wwwroot\INTERMESA\App_Data /T /E /G "TODOS":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Img /T /E /G "TODOS":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Down /T /E /G "TODOS":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Log /T /E /G "TODOS":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Temp /T /E /G "TODOS":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Uc\App_Data /T /E /G "TODOS":F 



cacls C:\Inetpub\wwwroot\INTERMESA /T /E /G "NETWORKSERVICE":R
cacls C:\Inetpub\wwwroot\INTERMESA\App_Data /T /E /G "NETWORKSERVICE":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Img /T /E /G "NETWORKSERVICE":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Down /T /E /G "NETWORKSERVICE":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Log /T /E /G "NETWORKSERVICE":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Temp /T /E /G "NETWORKSERVICE":W 
cacls C:\Inetpub\wwwroot\INTERMESA\Uc\App_Data /T /E /G "NETWORKSERVICE":F 
