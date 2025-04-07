import { LightningElement } from 'lwc';
import testFormula from '@salesforce/apex/EvalApexDemo.testFormula';
import getObjectInfo from '@salesforce/apex/EvalApexDemo.getObjectInfo';
import getWrapperFields from '@salesforce/apex/EvalApexDemo.getWrapperFields';


export default class EvalApexDemo extends LightningElement {

    formulaType;
    recordId;
    recordId2;
    formula1;
    formula2;
    result1;
    result2;
    result21;
    result22;
    userMode=false;
    additionalInfo;

    additionalInfoType;

    get options() {
        return [
            { label: 'Checkbox', value: 'Checkbox' },
            { label: 'Date', value: 'Date' },
            { label: 'DateTime', value: 'DateTime' },
            { label: 'Number', value: 'Number' },
            { label: 'Percent', value: 'Percent' },
            { label: 'Text', value: 'Text' },
            { label: 'Time', value: 'Time' },
        ];
    }

    handleChange(event) {
        this.formulaType = event.detail.value;
    }

    setValue1(event){
        this.formula1 = event.detail.value;
    }

    setValue2(event){
        this.formula2 = event.detail.value;
    }

    setRecordId(){
        this.recordId = event.detail.value;
        getObjectInfo({recordId: this.recordId}).then(data => this.objectInfo=data);
        if(this.recordId.startsWith('a08')){
            this.additionalInfoType='PaymentPlan Id';
        }else{
            this.additionalInfoType='Not used for this type';
        }
        if(this.recordId=='a08J8000009Di2MIAS'){
            this.formula1='record.Loan_Amount__c>=bound1 && record.Loan_Amount__c<=bound2';
            this.formula2='record.Loan_Amount__c>=bound3 && record.Loan_Amount__c<=bound4';
            this.additionalInfo='a0BJ80000009nDbMAI';
        }else{
            this.formula1='';
            this.formula2='';
            this.result1='';
            this.result2='';
            this.additionalInfo='';
        }

    }
    setRecordId2(){
        this.recordId2 = event.detail.value;
    }

    setOptionalFields(event){
        this.userMode=event.target.checked;
    }

    objectInfo;
    calculate(){
        getObjectInfo({recordId: this.recordId}).then(data => this.objectInfo=data);

        if(!this.optionalFields)this.optionalFields=null;
        if(this.formula1){
            testFormula({recordId: this.recordId , formulaType : this.formulaType,formulaValue : this.formula1,userMode : this.userMode,additionalInfo : this.additionalInfo}).then(data => {
                if(this.formulaType=='Checkbox'){
                    this.result1=data?'true':'false';
                }else{
                    this.result1=data;
                }
            });
        }
        if(this.formula2){
            testFormula({recordId: this.recordId , formulaType : this.formulaType,formulaValue : this.formula2,userMode : this.userMode,additionalInfo : this.additionalInfo}).then(data => {
                if(this.formulaType=='Checkbox'){
                    this.result2=data?'true':'false';
                }else{
                    this.result2=data;
                }
            });
        }
        if(this.formula1&&this.recordId2){
            testFormula({recordId: this.recordId2 , formulaType : this.formulaType,formulaValue : this.formula1,userMode : this.userMode,additionalInfo : this.additionalInfo}).then(data => {
                if(this.formulaType=='Checkbox'){
                    this.result21=data?'true':'false';
                }else{
                    this.result21=data;
                }
            });
        }
        if(this.formula2&&this.recordId2){
            testFormula({recordId: this.recordId2 , formulaType : this.formulaType,formulaValue : this.formula2,userMode : this.userMode,additionalInfo : this.additionalInfo}).then(data => {
                if(this.formulaType=='Checkbox'){
                    this.result22=data?'true':'false';
                }else{
                    this.result22=data;
                }
            });
        }
    }

    setAdditionInfo(){
        this.additionalInfo=event.target.value;
    }


    displayModal;
    fieldDescriptions;
    async openWrapperInfo(event){
        this.fieldDescriptions=[];
        let tmpFieldDescription;
        await getWrapperFields({wrapperName :event.target.dataset.wrapper}).then(data => {
            console.log('data :' + JSON.stringify(data));
            tmpFieldDescription = data;
        });
        console.log('tmpFieldDescription :' + JSON.stringify(tmpFieldDescription));
        for (let fieldName in tmpFieldDescription) {
            this.fieldDescriptions.push({description:tmpFieldDescription[fieldName], fieldName:fieldName});
         }
        this.displayModal=true;
        console.log('values : '+JSON.stringify(this.fieldDescriptions));
    }

    closeWrapperInformation(){
        this.displayModal=false;
    }


}