*** Settings ***
Documentation   Certification II BOT
Library         RPA.Browser.Selenium
Library         RPA.Excel.Files
Library         RPA.PDF
Library         RPA.HTTP
Library         RPA.Tables
Library         RPA.Archive
Library         Dialogs
Library         RPA.Robocloud.Secrets


*** Keywords ***
Get and log value in Secret Vault
  ${secret}=  Get Secret    credentials
  Log  ${secret}[robotsparebininc]

*** Keywords ***
Open RobotSpareBin Industries Inc Website
  Open Available Browser   https://robotsparebinindustries.com/#/robot-order  

*** Keywords ***
Close annoying modal
  Click Button    OK

*** Keywords ***
Download orders Excel File
  ${url}=  Get Value From User  Input orders.csv URL  
  Download     ${url}  overwrite=TRUE
  ${orders} =  Read Table From Csv    orders.csv
  Trim Empty Rows  ${orders}
  FOR  ${row}  IN  @{orders}
  Wait Until Keyword Succeeds  5x  1.5s  Close annoying modal
  Wait Until Keyword Succeeds  5x  1.5s  Order Robots from website using Excel file  ${row}
  Wait Until Keyword Succeeds  5x  1.5s  Screenshot the robot and convert that and HTML receipt to PDF  ${row}
  END   
  [ Teardown ]   Close Browser

*** Keywords ***
Order Robots from website using Excel file
  [ARGUMENTS]   ${row}
  Wait Until Page Contains Element  head
  Select From List By Index    head    ${row}[Head]
  Select Radio Button          body    ${row}[Body]
  Input Text                   xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]
  Input Text                   address    ${row}[Address]  
  Click Button                 preview
  Click Button                 order 
  Wait Until Page Contains Element  order-another

*** Keywords ***
Screenshot the robot and convert that and HTML receipt to PDF
  [ARGUMENTS]        ${row}
  ${order_receipt}=  Get Element Attribute    id:receipt   outerHTML 
  Html To Pdf        ${order_receipt}   ${CURDIR}${/}output${/}${row}[Order number].pdf  
  Screenshot         robot-preview-image  ${CURDIR}${/}output${/}${row}[Order number].png  
  ${robot_preview}=  Create List  ${CURDIR}${/}output${/}${row}[Order number].pdf  ${CURDIR}${/}output${/}${row}[Order number].png
  Add Files to PDF   ${robot_preview}  ${CURDIR}${/}output${/}${row}[Order number].pdf  
  Click Button       order-another

*** Keywords ***
Zip Output Files
  Archive Folder With Zip  ${CURDIR}${/}output  Output.zip  exclude=*.png

*** Tasks ***
Order Robot from website and save the receipt into PDF and zip files.
    Get and log value in Secret Vault
    Open RobotSpareBin Industries Inc Website
    Download orders Excel File
    Zip Output Files
    Log  Done.
