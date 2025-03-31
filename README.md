
# Project Title

This git contains all the source needed to run the demo shown into the presentation 






## Requirements 

Deploy the whole source inside a sandbox
Run the following script to create records inside the org

```java
INSERT new InterestRatePolicy__c(Boundary1__c=10000.0,Boundary2__c=40000.0,Boundary3__c=60000.0,Boundary4__c=500000.0,number__c=5.0,rate1__c=5.0,rate2__c=6.0,rate3__c=7.0,Name='Short Term');
INSERT new InterestRatePolicy__c(Boundary1__c=10000.0,Boundary2__c=40000.0,Boundary3__c=70000.0,Boundary4__c=500000.0,number__c=10.0,rate1__c=5.5,rate2__c=6.7,rate3__c=7.5,Name='Medium Term');
INSERT new InterestRatePolicy__c(Boundary1__c=10000.0,Boundary2__c=40000.0,Boundary3__c=60000.0,Boundary4__c=500000.0,number__c=15.0,rate1__c=6.5,rate2__c=7.7,rate3__c=8.8,Name='Long Term');
INSERT new LoanApplication__c(Loan_Amount__c=70000.0,Name='Application1');
```


## Run

open the following url to test yourself :

https://XXXXXX.lightning.force.com/lightning/cmp/c__loanApplicationDemo

for this demo, you'll need to create an Account and a contact at least. Replace the id with your own record id

https://XXXXXX.lightning.force.com/lightning/cmp/c__evalApexDemo
