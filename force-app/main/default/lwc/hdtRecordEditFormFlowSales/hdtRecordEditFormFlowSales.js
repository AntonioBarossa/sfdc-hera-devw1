import { LightningElement, api, track , wire} from 'lwc';
import cancelCase from '@salesforce/apex/HDT_LC_RecordEditFormSales.cancelCase';
import confirmForApproval from '@salesforce/apex/HDT_LC_RecordEditFormSales.confirmForApproval';
import savePractice from '@salesforce/apex/HDT_LC_RecordEditFormSales.savePractice';
import saveDraft from '@salesforce/apex/HDT_LC_RecordEditFormSales.saveDraft';
import getActivity from '@salesforce/apex/HDT_LC_RecordEditFormSales.getActivity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class HdtRecordEditFormFlowSales extends NavigationMixin(LightningElement){
    @api processtype;
    @api objectName = 'Case';
    @api recordid;
    @api accountId;
    @api saveButton;
    @api cancelButton;
    @api draftButton;
    @api acceptedFormats = ['.pdf', '.png'];
    @api statoApp = 'Nessuna Richiesta Inviata';
    @api saveInDraft;
    @api disabledInp = false;
    @api cancelCase;
    @api isRunFromFlow= false;
    @track showOperationSubType= false;
    @track selectedOperationType;
    @track selectedOperationSubType;
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

    get disabledContract(){
        if(this.isBonus) return true;
        return this.disabledInp;
    }

    get isBonus(){
        return this.processtype=="Contratti/Bonus Commerciale";
    }

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
            console.log('******:' + element.value);
            console.log('******:' + element.fieldName);
            if(element.fieldName=="Contract__c"){
                if(element.value!= null && element.value!= ""){
                    cs.Contract__c=element.value;
                }
            }else if(element.fieldName=="ReassignmentReason__c"){
                if(element.value!= null){
                    cs.ReassignmentReason__c=element.value;
                }
            }
            else if(element.fieldName=="Note__c"){
                if(element.value!= null && element.value!= ""){
                    cs.Note__c=element.value;
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
            saveDraft({caseId: this.recordid, accountId: this.accountId, caseob: cs}).then(result => {
                // const redirect= new CustomEvent('closeTab');
                // this.dispatchEvent(redirect);
                const event = new ShowToastEvent({
                    message: 'Case Salvato con Successo!',
                    variant: 'success',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordid,
                            objectApiName: 'Case',
                            actionName: 'view'
                        }
                    });
                const closeclickedevt = new CustomEvent('closeaction');
                this.dispatchEvent(closeclickedevt); 
                console.log(result);
                }).catch(error => {
                    console.log(error);
                });
        console.log('draft handle');

    }
    handleCancel(){
        cancelCase({caseId: this.recordid}).then(result => {
            console.log(result);
            const event = new ShowToastEvent({
                message: 'Case Annullato!',
                variant: 'success',
                mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordid,
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                });
                    const closeclickedevt = new CustomEvent('closeaction');
                    this.dispatchEvent(closeclickedevt); 
            }).catch(error => {
                console.log(error);
            });
    }

    submitForApproval(){
        this.preloading= true;
        confirmForApproval({caseId: this.recordid, accountId: this.accountId}).then(result => {
            if(result == true){
                const event = new ShowToastEvent({
                    message: 'Approvazione già richiesta',
                    variant: 'warning',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.preloading= false;

            }
            else{

                    const closeclickedevt = new CustomEvent('closeaction');
                    this.dispatchEvent(closeclickedevt); 
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
            }else if(element.fieldName=="Note__c"){
                if(element.value!= null){
                    cs.Note__c=element.value;
                }
            }
        },this);
        if(this.selectedOperationType != null && this.selectedOperationType != undefined && this.selectedOperationType!= "" ){
            cs.OperationType__c = this.selectedOperationType;
                 
        }
        else{
            validated= false;   
        }
        let operationSubType = this.template.querySelector("[data-id='operationSubType']");
        if(this.selectedOperationType == 'Bonus commerciale' && (operationSubType == null || operationSubType == undefined || operationSubType == "" )){
            validated= false; 
        }
        if(operationSubType != undefined){
            cs.OperationSubType__c= operationSubType.value;
        }
        console.log(cs);
        if(validated){
            savePractice({caseId: this.recordid, accountId: this.accountId, caseob: cs}).then(result => {
                // const redirect= new CustomEvent('closeTab');
                // this.dispatchEvent(redirect);
                if(result == 'success'){
                    const event = new ShowToastEvent({
                        message: 'Case Confermato',
                        variant: 'success',
                        mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordid,
                                objectApiName: 'Case',
                                actionName: 'view'
                            }
                        });
                        const closeclickedevt = new CustomEvent('closeaction');
                        this.dispatchEvent(closeclickedevt); 
                    console.log(result);
                }
                else if(result == 'success2'){
                    const event = new ShowToastEvent({
                        message: 'Attività Approvativa Creata',
                        variant: 'success',
                        mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordid,
                                objectApiName: 'Case',
                                actionName: 'view'
                            }
                        });
                        const closeclickedevt = new CustomEvent('closeaction');
                        this.dispatchEvent(closeclickedevt); 
                    console.log(result);
                }
                else if(result == 'annulla'){
                    const event = new ShowToastEvent({
                        message: 'l\'approvazione ha dato esito KO, annulla il caso',
                        variant: 'warning',
                        mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                }
                else if(result == 'aperta'){
                    const event = new ShowToastEvent({
                        message: 'l\activity di approvazione è ancora aperta, attendi la sua chiusura',
                        variant: 'warning',
                        mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                }
                
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
        console.log(this.recordid);
        console.log("AccountID:" + this.accountId);
        console.log(this.objectName);
        console.log("isFromReturnFlow:" + this.isRunFromFlow);
        
        getActivity({caseId: this.recordid}).then(result => {
            console.log("resu" + JSON.stringify(result));
            if(result != null ){
                let cas = result.c;
                this.disabledInp= result.disabled;
                this.selectedOperationSubType = cas.OperationSubType__c;
                this.selectedOperationType = cas.OperationType__c;
                if(this.selectedOperationType == 'Bonus commerciale'){
                    this.showOperationSubType = true;
                    this.selectedOperationSubType = cas.OperationSubType__c;
                }
            }
            console.log("SONO RIGA 222");

        });
       /* if(this.isRunFromFlow == false){
            console.log("PROVACURRENTPAGE:" + JSON.stringify(this.currentPageReference));
            this.recordid= this.currentPageReference.state.c__caseId;
        }*/

    }
    handleOnLoad(event){
        if(this.recordid != null){
        var record = event.detail.records;
        var fields = record[this.recordid].fields;
            if(fields.Phase__c != undefined){
                if(fields.Phase__c.value == 'In Attesa Approvazione'){
                    this.disableConfirmButton= true;
                }
            }
        }
    }
}