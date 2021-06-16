import { LightningElement, api, track , wire} from 'lwc';
import cancelCase from '@salesforce/apex/HDT_LC_RecordEditFormSales.cancelCase';
import confirmForApproval from '@salesforce/apex/HDT_LC_RecordEditFormSales.confirmForApproval';
import savePractice from '@salesforce/apex/HDT_LC_RecordEditFormSales.savePractice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class HdtRecordEditFormFlowSales extends NavigationMixin(LightningElement){
    @api processType;
    @api objectName;
    @api recordId;
    @api accountId;
    @api saveButton;
    @api cancelButton;
    @api draftButton;
    @api isRunFromFlow= false;
    @track showOperationSubType= false;
    @track selectedOperationType;
    @track showSubmitForApprovalButton=false;
    @track disableConfirmButton= false;
    @track preloading= false;
    operationTypeOptions=[
        {label:'Accollo totale', value:'Accollo totale'},
        {label:'Accollo parziale', value:'Accollo parziale'},
        {label:'Bonus commerciale', value:'Bonus commerciale'}
    ];
    operationSubTypeOptions =[
        {label:'Risarcimenti danni', value:'Risarcimenti danni'},
        {label:'Prezzo energia negoziato', value:'Prezzo energia negoziato'},
        {label:'Rimborso totale bollette', value:'Rimborso totale bollette'},
        {label:'Rimborso parziale bollette', value:'Rimborso parziale bollette'}
    ];

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }
    handleOperationTypeChange(event){
        console.log('Changed');
        var selected = event.detail.value;
        this.selectedOperationType = selected;
        console.log(this.selectedOperationType);
        if(this.selectedOperationType == 'Bonus commerciale'){
            this.showOperationSubType = true;
        }else{
            this.showOperationSubType = false;
        }
    }
    handleReassignmentReasonChange(event){
        if(event.detail.value !=undefined &&event.detail.value !=""){
            this.showSubmitForApprovalButton= true;
            this.disableConfirmButton= true;
        }else{
            this.showSubmitForApprovalButton= false;
            this.disableConfirmButton= false;
        }
    }
    handleDraft(event){

        let casefields = this.template.querySelectorAll('lightning-input-field');
        let cs ={}; 
        casefields.forEach(function(element){
            if(element.fieldName=="Contract__c"){
                if(element.value!= null && element.value!= ""){
                    cs.Contract__c=element.value;
                }
            }else if(element.fieldName=="ReassignmentReason__c"){
                if(element.value!= null){
                    cs.ReassignmentReason__c=element.value;
                }
            }
        },this);
        if(this.selectedOperationType != null && this.selectedOperationType != undefined && this.selectedOperationType!= "" ){
            cs.OperationType__c = this.selectedOperationType;
        }
        let operationSubType = this.template.querySelector("[data-id='operationSubType']");
        if(operationSubType != undefined){
            cs.OperationSubType__c= operationSubType.value;
        }
        console.log(cs);
            saveDraft({caseId: this.recordId, accountId: this.accountId, caseob: cs}).then(result => {
                // const redirect= new CustomEvent('closeTab');
                // this.dispatchEvent(redirect);
                console.log(result);
                }).catch(error => {
                    console.log(error);
                });
        console.log('draft handle');

    }
    handleCancel(){
        cancelCase({caseId: this.recordId}).then(result => {
            console.log(result);
            }).catch(error => {
                console.log(error);
            });
    }

    submitForApproval(){
        this.preloading= true;
        confirmForApproval({caseId: this.recordId, accountId: this.accountId}).then(result => {
            if(result == true){
                const event = new ShowToastEvent({
                    message: 'Approvazione già richiesta',
                    variant: 'warning',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.preloading= false;

            }
            // const redirect= new CustomEvent('closetab');
            // this.dispatchEvent(redirect);
            console.log(result);
            }).catch(error => {
                console.log(error);
            });
    }

    handleSave(){
        let casefields = this.template.querySelectorAll('lightning-input-field');
        let validated= true;
        let cs ={}; 
        casefields.forEach(function(element){
            if(element.fieldName=="Contract__c"){
                if(element.value!= null && element.value!= ""){
                    cs.Contract__c=element.value;
                }else{
                    validated= false;        
                }
            }else if(element.fieldName=="ReassignmentReason__c"){
                if(element.value!= null){
                    cs.ReassignmentReason__c=element.value;
                }
            }
        },this);
        if(this.selectedOperationType != null && this.selectedOperationType != undefined && this.selectedOperationType!= "" ){
            cs.OperationType__c = this.selectedOperationType;
            validated= false;        
        }
        let operationSubType = this.template.querySelector("[data-id='operationSubType']");
        if(operationSubType != undefined){
            cs.OperationSubType__c= operationSubType.value;
        }
        console.log(cs);
        if(validated){
            savePractice({caseId: this.recordId, accountId: this.accountId, caseob: cs}).then(result => {
                // const redirect= new CustomEvent('closeTab');
                // this.dispatchEvent(redirect);
                console.log(result);
                }).catch(error => {
                    console.log(error);
                });
        }else{
            const event = new ShowToastEvent({
                message: 'Popolare i campi necessari',
                variant: 'error',
                mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.preloading= false;
        }
        
    }
    connectedCallback(){
        console.log(this.recordId);
        console.log(this.objectName);
        if(this.isRunFromFlow == false){
            this.recordId= this.currentPageReference.state.c__caseId;
        }

    }
    handleOnLoad(event){
        if(this.recordId != null){
        var record = event.detail.records;
        var fields = record[this.recordId].fields;
            if(fields.Phase__c != undefined){
                if(fields.Phase__c.value == 'In Attesa Approvazione'){
                    this.disableConfirmButton= true;
                }
            }
        }
    }
}