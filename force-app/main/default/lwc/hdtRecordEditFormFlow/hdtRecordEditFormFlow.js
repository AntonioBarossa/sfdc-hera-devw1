import { LightningElement, track,wire,api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getFields';
import validateRecord from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.validateRecord';
import getContentDocs from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getContentDocs';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';

import ASSISTED from '@salesforce/schema/Case.CutomerAssisted__c';
import TYPE from '@salesforce/schema/Case.Type';
import ACCOUNTID from '@salesforce/schema/Case.AccountId';

export default class HdtRecordEditFormFlow extends LightningElement {

    @api processType;
    @api objectName;
    @api recordId;
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
    @api cancelCase;
    @api addContentDocument;
    @api contentDocumentLabel;
    @api acceptedFormats;
    @api nextStep;
    @api showReadOnly;
    @api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelInputSection;
    @api labelReadOnlySection;
    @api availableActions = [];
    @api variantSaveButton;
    @api outputId;
    @api documentRecordId;

    @track errorMessage;
    @track error;
    @track fieldsJSON;
    @track fieldsJSONReadOnly;
    @track wiredResponse;
    @track firstColumn = [];
    @track secondColumn = [];
    @track firstColumnReadOnly = [];
    @track secondColumnReadOnly = [];
    @track validateClass="";
    @track contentDocument;
    @track formats=[];
    @track showInputSection = false;
    @track variablesLoaded = false;
    //@track showNotificationMessage = false;
    //@track notificationDescription = '';
    //@track notificationType = '';
    //@track delay = 3000;
    @track show = false;
    showCustomLabels= false;

    get customLabelClass(){
        if(this.density)    return "slds-form-element "+(this.density=="comfy"? "slds-form-element_stacked" : "slds-form-element_horizontal");
        let clist = this.template.querySelector('lightning-input-field.slds-form-element')?.classList?.value;
        return clist? clist : "slds-form-element slds-form-element_horizontal";
    }

    @track assisted;
    @track type;
    @track caseAccId;
    @wire(getRecord, { recordId: '$recordId', fields: [ASSISTED,TYPE,ACCOUNTID] })
    wiredRecord({ error, data }) {
        if (data) {
            this.assisted = data.fields.CutomerAssisted__c.value;
            this.type = data.fields.Type.value;
            this.caseAccId = data.fields.AccountId.value;
        }
    }


    @wire(getFields, { processType: '$processType' }) 
        wiredFieldsJSON ({ error, data }) {
            if (data) {
                console.log('### Struttura Form ' + JSON.stringify(data));
                console.log('### Object Name ' + this.objectName);
                console.log('### RecordId ' + this.recordId);
                console.log('### RecordType ' + this.recordType);
                this.wiredResponse = JSON.parse(data);
                this.validateClass = this.wiredResponse[0].ValidateClass__c;
                if(this.wiredResponse[0].hasOwnProperty("FieldsJSON__c")){
                    this.fieldsJSON = JSON.parse(this.wiredResponse[0].FieldsJSON__c);
                    this.fieldsJSON.forEach(obj => {
                        if(obj.Column == 1){
                            this.firstColumn.push(obj);
                        }else{
                            this.secondColumn.push(obj);
                        }
                    });
                    this.showInputSection = true;
                }
                if(this.showReadOnly){
                    this.fieldsJSONReadOnly = JSON.parse(this.wiredResponse[0].ReadOnlyFields__c);
                    this.fieldsJSONReadOnly.forEach(obj => {
                        if(obj.Column == 1){
                            this.firstColumnReadOnly.push(obj);
                        }else{
                            this.secondColumnReadOnly.push(obj);
                        }
                    });
                }
                
                if(this.processType.localeCompare('Richiesta Parere') === 0
                    || this.processType.localeCompare('Richiesta Parere Esercizio Diritti Privacy') === 0){
                    this.variablesLoaded = true;
                }else{
                    if(this.recordId != null){
                        updateRecord({fields: { Id: this.recordId }}).then(() => {
                        console.log('Record Refreshato');
                        console.log('Prima Colonna ' + JSON.stringify(this.firstColumn));
                        console.log('Seconda Colonna ' + JSON.stringify(this.secondColumn));
                        this.variablesLoaded = true;
                        }).catch(error => {
                            console.log('Error Refreshing record');
                            this.error = true;
                        });
                    }
                    else
                    {
                        this.variablesLoaded = true;
                    }
                }
            } else if (error) {
                this.error = true;
                this.errorMessage = error;
                this.errorMessage = error.message;
            }
        }

        updateRecordView(recordId) {
            updateRecord({fields: { Id: recordId }});
        }

        @api
        get variantButton() {
            if(this.variantSaveButton != null && this.variantSaveButton != "" && this.variantSaveButton != "undefined" )
            return this.variantSaveButton;
        else
            return "brand";
        }
        /*
        @wire(getContentDocs, {arecordId : '$recordId'}) 
            wiredContentDocument({ error, data }) {
                console.log('finitoo ' + JSON.stringify(error));
                if (data) {
                    this.contentDocument = data;
                } else if (error) {
                    this.error = true;
                    this.errorMessage = error;
                }
            }
        */
    selectContentDocument(){

        if(this.documentRecordId == null || this.documentRecordId == undefined || this.documentRecordId == ''){
            this.documentRecordId = this.recordId;
        }

        getContentDocs({
            arecordId: this.documentRecordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                if(Object.keys(result).length > 0 )
                    this.contentDocument = result;
                else
                this.contentDocument = null;
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    connectedCallback(){
        if(this.addContentDocument){
            this.selectContentDocument();
        }
        console.log('### Accepted Format ' + this.acceptedFormats);
        if(this.acceptedFormats){
            console.log(this.acceptedFormats);
            this.formats = this.acceptedFormats.split(";");
            console.log(JSON.stringify(this.formats));
        }
        console.log('### PreviousButton -> ' +this.previousButton);
        if(this.previousButton && !this.availableActions.find(action => action === 'BACK')){
            this.previousButton = false;
        }
        console.log('### ProcessType -> ' + this.processType);
        console.log('### END Connected ###');
        
    }
    renderedCallback(){
        //this.installmentsLogic();
    }
    /*get formats(){
        var formats = [];
        console.log(this.acceptedFormats);
        if(this.acceptedFormats){
            console.log(this.acceptedFormats);
            formats = this.acceptedFormats.split(";");
            console.log(JSON.stringify(formats));
        }
        return formats;
    }*/
    handleUploadFinished(){
        this.selectContentDocument();
    }
    handleActionFinished(){
        this.selectContentDocument();
    }
    getRecordType(){
        if(this.recordType)
            return this.recordType;
        else
            return null;
    }
    handleSuccess(event) {

        console.log('#Record Id Created --> ' +event.detail.id);

        if(this.recordId == null || this.recordId == undefined){

            this.outputId = event.detail.id;

        }

        if(this.availableActions.find(action => action === 'FINISH')){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: event.detail.apiName + ' aggiornato.',
                    variant: 'success',
                }),
            );
        }
        this.handleGoNext();
    }
    handleOnLoad(event){
        if(this.recordId != null){
        var record = event.detail.records;
        var fields = record[this.recordId].fields;
        this.installmentsLogic();
        console.log('Edit Form Loaded ' + fields);
        
        }
        this.showCustomLabels=true;
    }

    handleError(event){
        console.log('Error Loading: ' + JSON.stringify(event.detail));
        let message = '';
        let obj = event.detail.output.fieldErrors;
        if (Object.keys(obj).length > 0) {
            message = obj[Object.keys(obj)[0]][0].message;
        } else {
            // Errore da validation rules con error location "top of the page"
            message = event.detail.detail;
        }

        console.log('Error Loading message ' + message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Errore',
                message: message,
                variant: 'error',
            }),
        );
    }

    handleDraft(event){
        console.log('draft handle');
        if(event.target.name === 'draft'){

            this.saveInDraft = true;
            this.cancelCase  = false;

        } else if(event.target.name === 'cancel'){

            this.cancelCase = true;
            this.saveInDraft = false;

        }

        this.template.querySelector('lightning-record-edit-form').submit();
    }

    showMessage(title,message,variant){

        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

    handleSubmit(event){
        if(this.recordId != null 
            || this.processType.localeCompare('Richiesta Parere') === 0
            || this.processType.localeCompare('Richiesta Parere Esercizio Diritti Privacy') === 0){
            event.preventDefault();       // stop the form from submitting
            this.saveInDraft = false;
            this.cancelCase = false;
            const fields = event.detail.fields;
            console.log('fields ' + JSON.stringify(fields));
            if(this.validateClass){
                validateRecord({
                    validateClass: this.validateClass,
                    fields: JSON.stringify(fields),
                    recordId: this.recordId
                })
                    .then(result => {
                        var resultWrapper = JSON.parse(result);
                        if(resultWrapper.outcomeCode === "OK"){ 
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        }else{
                            console.log('ErrorMessage: ' +resultWrapper.outcomeDescription);
                            this.showMessage('Errore',resultWrapper.outcomeDescription,'error');  
                        }
                    })
                    .catch(error => {
                        this.error = true;
                    });
            }else{
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }
    }

    handleAttributeChange() {
        // notify the flow of the new value 
        const attributeChangeEvent = new FlowAttributeChangeEvent('varName', 'value');
        this.dispatchEvent(attributeChangeEvent);
    }

    handleGoNext() {
        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }
    
    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    selector(fieldName){

        return this.template.querySelector('lightning-input-field[data-id="'+ fieldName + '"]') != null
        ?this.template.querySelector('lightning-input-field[data-id="'+ fieldName + '"]')
        :null;

    }

    objSelector(fieldName){
        return !(Object.keys(this.firstColumn.filter(element => element['FieldName'] === fieldName)).length === 0) 
        ? this.firstColumn.filter(element => element['FieldName'] === fieldName)
        : this.secondColumn.filter(element => element['FieldName'] === fieldName);
    }

    virtualOnChange(event){
        return;
    }

    handleChange(event){
        this.virtualOnChange(event);
        //Reclami customizations
        this.complaintsLogic();
        //PianoRata customizations
        this.installmentsLogic();
        //Comunicazione pagamenti customizations
        this.paymentLogic();
        //RimborsoCustomization
        this.reimbursmentLogic();
        //DisconnectableLogic
        this.disconnectableLogic();
        //Variazioni customLogic
        this.variationsLogic();     //MODIFICA 21/07/22 marco.arci@webresults.it Logica form compilazione Variazioni
    }

    variationsLogic(){
        //Sottoprocessi di varaiazioni
        if(['AGEVOLAZIONE','COMPONENTI RESIDENTI','COMPONENTI NON RESIDENTI','COABITAZIONI','DATI CATASTALI',
            'ISTAT/RONCHI','SUPERFICIE','DOMICILIATO IN NUCLEO RESIDENTE','RID. AGEV. DOPO ACCERTAMENTO'].includes(this.processType.toUpperCase())){
            let RequestSource = this.selector('RequestSource__c');
            let SubscriberType = this.selector('SubscriberType__c');
            if(RequestSource.value.toUpperCase() != 'DA CONTRIBUENTE'){
                SubscriberType.required = false;
                SubscriberType.value = null;
                SubscriberType.disabled = true;
            } else {
                SubscriberType.required = true;
                SubscriberType.disabled = false;
            }
        }
    }

    paymentLogic(){ 
        /*if(this.type == 'Comunicazione Pagamento'){
            let accountholderTypeBeneficiary = this.selector('AccountholderTypeBeneficiary__c');
            console.log('#accountholderTypeBeneficiary : ' + accountholderTypeBeneficiary.value);
            if(accountholderTypeBeneficiary != null){
                let beneficiaryAccount = this.selector('BeneficiaryAccount__c');
                if(accountholderTypeBeneficiary.value !== '' && accountholderTypeBeneficiary.value !== undefined && accountholderTypeBeneficiary !== null && accountholderTypeBeneficiary.value == 'Stesso Sottoscrittore'){
                    beneficiaryAccount.disabled = true;
                    console.log('#accountId : ' + this.caseAccId);
                    beneficiaryAccount.value = this.caseAccId;
                }else{
                    beneficiaryAccount.disabled = false;
                }
            }
            
        }*/
        if(this.type == 'Comunicazione Pagamento'){
            let canalePagamento = this.selector('ChannelOfPayment__c');
            if(canalePagamento && canalePagamento.value === 'Banca BONIFICO'){
                this.labelSaveButton  = 'Avanti';
            }else{
                this.labelSaveButton  = 'Conferma Pratica';
            }
        }
    }

    complaintsLogic(){
        let five = this.objSelector('FithLevelComplaintClassification__c');
        console.log('Five '+five);
        let channel = this.objSelector('ComplaintEntryChannel__c');
        console.log('Channel '+channel);
        if(!(Object.keys(five).length === 0)){
            let fifthLevel = this.selector('FithLevelComplaintClassification__c');
            console.log('#Valore quinto livello -->' +fifthLevel.value)
            if(fifthLevel != null){
                let soldBy = this.selector('SoldBy__c');
                if(soldBy != null){
                    if(fifthLevel.value !== '' && fifthLevel.value !== undefined && fifthLevel !== null){
                        soldBy.disabled = false;
                    }else{
                        soldBy.disabled = true;
                    }
                }
            }
        } else if(!(Object.keys(channel).length === 0)){
            let entryChannel = this.selector('ComplaintEntryChannel__c');
            console.log('#Valore Entry Channel --> ' +entryChannel.value);
            let address = this.selector('CompliantOriginEmail__c');
            if(entryChannel.value === 'Email' || entryChannel.value === 'PEC'){
                address.required = true;
            } else {
                address.required = false;
            }
        }
    }

    installmentsLogic(){
        console.log('Rec ' + this.type);
        let reasonObj =  this.objSelector('Reason__c');
        console.log('#Reason --> ' + JSON.stringify(reasonObj));
        let paymentType = this.objSelector('PaymentType__c');
        console.log('#PaymentType --> ' + JSON.stringify(paymentType));
        if(!(Object.keys(reasonObj).length === 0)){
            let reason = this.selector('Reason__c');
            if(reason != null){
                console.log('#Valore Reason --> ' + reason.value);
                if(reason.value && reason.value != ''){
                    if(!(Object.keys(paymentType).length === 0)){
                        console.log('Inside Condition Installments');
                        let payType = this.selector('PaymentType__c');
                        let workStatus = this.selector('WorkStatus__c');
                        let refundableEscape = this.selector('RefundableEscape__c');
                        console.log('#Valore payType -> ' + payType.value);
                        if(reason.value.localeCompare('Assistenza sociale (cliente)') === 0 && payType != null){
                            if(this.assisted){
                                payType.disabled = true;
                                payType.value = 'Totalmente dal Cliente';
                            }
                            else payType.disabled = false;
                            workStatus.disabled = true;
                            workStatus.required = false;
                            workStatus.value = '';
                        }else if(reason.value.localeCompare('Assistenza sociale (ente)') === 0 && payType != null){
                            if(this.assisted){
                                payType.disabled = true;
                                payType.value = 'In compartecipazione o totalmente da istituzioni pubbliche';
                            }
                            else payType.disabled = false;
                            workStatus.disabled = true;
                            workStatus.required = false;
                            workStatus.value = '';
                        }else if(reason.value.localeCompare('Fattura SD') === 0 && workStatus != null){
                            workStatus.disabled = false;
                            workStatus.required = true;
                        }else if(reason.value.localeCompare('Bolletta Fuga H2O') === 0 && refundableEscape != null){
                            refundableEscape.disabled = false;
                            refundableEscape.required = false;
                        } 
                        else {
                            payType.disabled = true;
                            payType.value = '';
                            workStatus.disabled = true;
                            workStatus.required = false;
                            workStatus.value = '';
                        }
                    }
                }
            }
        }
        let depositObj = this.objSelector('Deposit__c');
        console.log('#Deposit --> ' + JSON.stringify(depositObj));
        if(!(Object.keys(depositObj).length === 0)){
            let deposit = this.selector('Deposit__c');
            console.log('#Deposit -> ' + deposit.value);
            if(deposit.value != null && deposit.value != undefined){
                let depositPaymentMode = this.selector('DepositPaymentMode__c');
                let sendPaperlessCode = this.selector('SendPaperlessCodeMode__c');
                let depositamount = this.selector('DepositAmount__c');
                let depositDate = this.selector('DepositPaymentDate__c');
                if(!deposit.value){
                    depositPaymentMode.disabled = true;
                    depositamount.disabled = true;
                    depositDate.disabled = true;
                    sendPaperlessCode.disabled = true;
                    depositPaymentMode.value = '';
                    depositamount.value = null;
                    depositDate.value = null;
                    sendPaperlessCode.value = '';
                } else {
                    depositPaymentMode.disabled = false;
                    depositamount.disabled = false;
                    depositDate.disabled = false;
                }
                if((depositPaymentMode.value === 'Paperless' || depositPaymentMode.value === 'Bonifico Paperless') && !depositPaymentMode.disabled){
                    sendPaperlessCode.disabled = false;
                }
            }
        }
        let depositPaymentModeObj = this.objSelector('DepositPaymentMode__c');
        console.log('#DepositPaymentMode --> ' + JSON.stringify(depositPaymentModeObj));
        if(!(Object.keys(depositPaymentModeObj).length === 0)){
            let depositPaymentMode = this.selector('DepositPaymentMode__c');
            console.log('#DepositPaymentMode -> ' + depositPaymentMode.value)
            if(depositPaymentMode.value !== null && depositPaymentMode.value !== undefined){
                let paperlessCode = this.selector('SendPaperlessCodeMode__c');
                if(depositPaymentMode.value === 'Paperless' || depositPaymentMode.value === 'Bonifico Paperless'){
                    paperlessCode.disabled = false;
                } else {
                    paperlessCode.disabled = true;
                }
            }
        }
        //let installmentTypeObj = this.objSelector('TypeInstallmentPlan__c');
        /*if(!(Object.keys(installmentTypeObj).length === 0)){
            let installmentType = this.selector('TypeInstallmentPlan__c');
            console.log('#InstallmentType -> ' + installmentType.value);
            if(installmentType.value !== null && installmentType.value !== undefined){
                let applicationInterestObj = this.objSelector('ApplicationInterests__c');
                if(!(Object.keys(installmentTypeObj).length === 0)){
                    let applicationInterest = this.selector('ApplicationInterests__c');
                    if(installmentType.value.includes('Solo Piano Mensile')){
                        applicationInterest.value = true;
                    } else {
                        applicationInterest.value = false;
                    }
                }
            }
        }*/
    }

    reimbursmentLogic()
    {
        let reimbursMethodObj = this.objSelector('RefundMethod__c');
        console.log('#Reimburs --> ' + JSON.stringify(reimbursMethodObj));
        if(!(Object.keys(reimbursMethodObj).length === 0))
        {
            let reimbursMethod = this.selector('RefundMethod__c');
            console.log('#Reimburs -> ' + reimbursMethod.value);
            if(reimbursMethod.value !== null && reimbursMethod.value !== undefined )
            {
                let beneficiaryAccountObj = this.objSelector('AccountholderTypeBeneficiary__c');
                console.log('#ReimbursAccount --> ' + JSON.stringify(reimbursMethodObj));
                if(!(Object.keys(beneficiaryAccountObj).length === 0))
                {
                    let beneficiaryAccount = this.selector('AccountholderTypeBeneficiary__c');
                    if(reimbursMethod.value === 'Compensazione')
                    {
                        beneficiaryAccount.required = false;
                    }
                    else
                    {
                        beneficiaryAccount.required = true;
                    }
                }
            }
        }
    }
    disconnectableLogic()
    {
        let disconnectableCategoryObj = this.objSelector('DisconnectibilityType__c');
        console.log('#DisconnectObject ---> ' + JSON.stringify(disconnectableCategoryObj));
        if(!(Object.keys(disconnectableCategoryObj).length === 0))
        {
            let disconnectableCategory = this.selector('DisconnectibilityType__c');
            console.log('#Disconnect -> ' + disconnectableCategory.value);
            let autocertAslObj = this.objSelector('SelfCertificationAcquisitionAsl__c');
            console.log('#AutocertObject ---> ' + JSON.stringify(autocertAslObj));
            if(disconnectableCategory.value !== null && disconnectableCategory.value !== undefined && disconnectableCategory.value === '01- App. medico terapeutiche')
            {
                if(!(Object.keys(autocertAslObj).length === 0))
                {
                    let autocertAsl = this.selector('SelfCertificationAcquisitionAsl__c');
                    console.log('#Autocert -> ' + autocertAsl.value);
                    autocertAsl.value = 'SI';
                }
            }
            else
            {
                if(!(Object.keys(autocertAslObj).length === 0))
                {
                    let autocertAsl = this.selector('SelfCertificationAcquisitionAsl__c');
                    console.log('#Autocert -> ' + autocertAsl.value);
                    autocertAsl.value = '';
                }
            }
        }
    }
}