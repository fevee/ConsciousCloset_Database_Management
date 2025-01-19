@echo off
set server=LAPTOP-KC5UKCA1\VENUS
set database=ConsciousCloset
set output_file=sales_report.txt

sqlcmd -S %server% -d %database% -E -i GenerateSalesReport.sql -o %output_file%

echo Data retrieval complete. Check %output_file% for the sales report.

pause  ::
