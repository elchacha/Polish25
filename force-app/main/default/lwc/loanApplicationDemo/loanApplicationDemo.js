import { LightningElement } from 'lwc';

import testMe from '@salesforce/apex/LoanApplicationFullDemo.testMe';


export default class LoanApplicationDemo extends LightningElement {

    loanAmount=70000;

    setAmount(event){
        this.loanAmount = event.detail.value;
    }

    plan1={};
    plan2={};
    plan3={};

    calculate(){
        this.loanApplicationId='a02KB00000BNvMSYA1';
        testMe({recordId: this.loanApplicationId , paymentName : 'Short Term',loanAmount:this.loanAmount}).then(data => {
            this.plan1=data;
        });
        testMe({recordId: this.loanApplicationId , paymentName : 'Medium Term',loanAmount:this.loanAmount}).then(data => {
            this.plan2=data;
        });
        testMe({recordId: this.loanApplicationId , paymentName : 'Long Term',loanAmount:this.loanAmount}).then(data => {
            this.plan3=data;
        });
    }


}