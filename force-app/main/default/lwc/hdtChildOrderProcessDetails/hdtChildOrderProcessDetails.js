import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateProcessStep from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.updateProcessStep';
//INIZIO SVILUPPI EVERIS
import updateOrder from '@salesforce/apex/HDT_LC_SelfReading.updateOrder';
import { getRecord, getFieldValue, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import  voltureEffectiveDateCheck from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.voltureEffectiveDateCheck';
import getDates from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.getDates';
import sendAdvanceDocumentation from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendAdvanceDocumentation';
import RETROACTIVE_DATE from '@salesforce/schema/Order.RetroactiveDate__c';
import EFFECTIVE_DATE from '@salesforce/schema/Order.EffectiveDate__c';
//FINE SVILUPPI EVERIS
import createActivityAccise from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.createActivityAccise'
import getQuoteTypeMtd from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd';
// @Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
import retrieveOrderCreditCheck from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.retrieveOrderCreditCheck';
import ConsumptionsCorrectionType__c from '@salesforce/schema/Case.ConsumptionsCorrectionType__c';
import SystemCapacity__c from '@salesforce/schema/Case.SystemCapacity__c';

class fieldData{
    constructor(label, apiname, typeVisibility, required, disabled, processVisibility, value) {
        this.label = label;
        this.apiname=apiname;
        this.typeVisibility = typeVisibility;
        this.required=required;
        this.disabled=disabled;
        this.processVisibility=processVisibility;
        this.value=value;
    }
    static justLabelAndVisibilityEx(label,typeVisibility){
        return new MyClass(label,null,typeVisibility);
    }
    
}
export default class hdtChildOrderProcessDetails extends LightningElement {
    @api order;
    title = '';
    isVisible = false;
    loading = false;
    moduleButtonVisibility = false;
    moduleButtonLabel = 'Modulo informativo';
    isAccountResidential;
    choosenSection = '';
    activeSections = [];
    @track availableSteps = [];
    @track availableStepsFirst = []; 
    @track confirmedSteps = [];
    @track pendingSteps = []
    loading = false;
    showModuloInformativo = false;
    showDelibera40 = false;
    showInviaModulistica = false;
    @track sectionDataToSubmit = {};
    @track sectionDiffDataToSubmit = {};
    lastStepNumber = 3;
    currentSection = {};
    currentSectionObjectApi = '';
    currentSectionRecordId = '';
    @track fields = {};
    extraFieldsToSubmit = {}; 
    @api mainOrderItem;
    wrapAddressObjectAttivazione = {};
    wrapAddressObjectSpedizione = {};
    @api analisiConsumi;
    acceptedFormatsIvaAcciseUpload = ['.pdf', '.png'];
    @track lastStepData = {};
    get orderWithData(){
        return { ...this.order, ...this.sectionDataToSubmit };
    }
    get previousTraderOptions(){ return [
        {"label":"ENEL ENERGIA SPA-10V0000006","value":"ENEL ENERGIA SPA-10V0000006"},
        {"label":"EDISON PER VOI -10V0000017","value":"EDISON PER VOI -10V0000017"},
        {"label":"ENI GAS & POWER-10V0000012","value":"ENI GAS & POWER-10V0000012"}
    ]};

    get isNotBillable(){
        return this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && !this.order.IsBillableVas__c;
    }
    get isBillable(){
        return this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && this.order.IsBillableVas__c;
    }

    //INIZIO SVILUPPI EVERIS
    @track readingCustomerDate;
    @track disabledReadingDate;
    @track isRetroactive = false;
    @track isSavedReading;
    @track outputFieldObj = {};
    @track isVolture;
    @track isReading;
    @track readingDisabled = false;
    //FINE SVILUPPI EVERIS
    sysdate(){
        var sysdateIso = new Date().toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return sysdateIso.substr(0, sysdateIso.indexOf('T'));
    }
    //FINE SVILUPPI EVERIS

    handleSectionDataToSubmitCollection(event){
        //EVERIS
        if(event.target.fieldName === 'EffectiveDate__c' && this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
            if(this.readingDisabled || this.order.ServicePoint__r.CommoditySector__c.localeCompare('Energia Elettrica') === 0){
                console.log('EffectiveDateValue -> ' + event.target.value);
                voltureEffectiveDateCheck({effectiveDate: event.target.value})
                    .then(result => {
                        console.log('Result -> '+result);
                        if(result === 1){
                            this.readingDisabled = false;
                        } else {
                            this.readingDisabled = true;
                        }
                    }).catch(error => {
                        console.log('Error -> ' +error);
                    });
            }
        }
        //EVERIS
        if(event.target.fieldName !== undefined){
            this.sectionDataToSubmit[event.target.fieldName] = event.target.value;
        }
        if(event.target.name !== undefined){
            this.sectionDataToSubmit[event.target.name] = event.target.value;
        }
        if(event.target.fieldName === 'VATfacilitationFlag__c' && event.target.value) {
            this.template.querySelector("[data-id='VAT__c']").disabled = false;
            this.template.querySelector("[data-id='VAT__c']").required = true;
            Promise.resolve().then(() => {
                const inputEle = this.template.querySelector("[data-id='VAT__c']");
                inputEle.reportValidity();
            });
        } else if(event.target.fieldName === 'VATfacilitationFlag__c' && !event.target.value) {
            this.template.querySelector("[data-id='VAT__c']").disabled = true;
            this.template.querySelector("[data-id='VAT__c']").required = false;
            Promise.resolve().then(() => {
                const inputEle = this.template.querySelector("[data-id='VAT__c']");
                inputEle.reportValidity();
            });
        }

        if(event.target.fieldName === 'FacilitationExcise__c' && event.target.value) {
            if(this.template.querySelector("[data-id='ExciseEle__c']") !== null) {
                this.template.querySelector("[data-id='ExciseEle__c']").disabled = false;
                this.template.querySelector("[data-id='ExciseEle__c']").required = true;
                Promise.resolve().then(() => {
                    const inputEle = this.template.querySelector("[data-id='ExciseEle__c']");
                    inputEle.reportValidity();
                });
            }
            if(this.template.querySelector("[data-id='ExciseGAS__c']") !== null) {
                this.template.querySelector("[data-id='ExciseGAS__c']").disabled = false;
                this.template.querySelector("[data-id='ExciseGAS__c']").required = true;
                Promise.resolve().then(() => {
                    const inputEle = this.template.querySelector("[data-id='ExciseGAS__c']");
                    inputEle.reportValidity();
                });
            }

        } else if(event.target.fieldName === 'FacilitationExcise__c' && !event.target.value) {
            if(this.template.querySelector("[data-id='ExciseEle__c']") !== null) {
                this.template.querySelector("[data-id='ExciseEle__c']").disabled = true;
                this.template.querySelector("[data-id='ExciseEle__c']").required = false;
                Promise.resolve().then(() => {
                    const inputEle = this.template.querySelector("[data-id='ExciseEle__c']");
                    inputEle.reportValidity();
                });
            }
            if(this.template.querySelector("[data-id='ExciseGAS__c']") !== null) {
                this.template.querySelector("[data-id='ExciseGAS__c']").disabled = true;
                this.template.querySelector("[data-id='ExciseGAS__c']").required = false;
                Promise.resolve().then(() => {
                    const inputEle = this.template.querySelector("[data-id='ExciseGAS__c']");
                    inputEle.reportValidity();
                });
            }
        }
        if (this.currentSection.name === 'dateOrdine') {
            if(event.target.fieldName === 'IsActivationDeferred__c') {
                console.log("IsActivationDeferred__c");
                this.pendingSteps.filter(section => section.name === 'dateOrdine')[0].data.filter(field => field.apiname === 'EffectiveDate__c')[0].typeVisibility = event.target.value;
                if (event.target.value && this.sectionDataToSubmit.EffectiveDate__c === undefined) {
                    this.sectionDataToSubmit['EffectiveDate__c'] = this.order.EffectiveDate__c;
                } else {
                    delete this.sectionDataToSubmit.EffectiveDate__c;
                }
            }
        }

        let draftData = this.sectionDataToSubmit;
        draftData.Id = this.currentSectionRecordId;
        if(this.lastStepNumber === this.currentSection.step) {
            this.lastStepData = draftData;
        }
        this.dispatchEvent(new CustomEvent('emitdraftdata', {detail: {
            objectApiName: this.currentSectionObjectApi,
            fields: draftData,
            lastStepData: this.lastStepData
        }}));
    }

    handleShowModuloInformativo(){
        if ((this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
            || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
            || this.order.RecordType.DeveloperName === 'HDT_RT_RiattivazioniNonMorose')
            && this.order.ServicePoint__c !== undefined
            && this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas') {
            this.showModuloInformativo = true;
        }
    };

    handleShowDelibera40(){
        if ((this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
            || this.order.RecordType.DeveloperName === 'HDT_RT_RiattivazioniNonMorose')
            && this.order.Deliberation__c === 'In Delibera'
            && this.order.ServicePoint__c !== undefined
            && this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas') {
            this.showDelibera40 = true;
        }
    } 

    handleShowInviaModulistica(){
        if(this.order.ServicePoint__c !== undefined && this.order.ServicePoint__r.MeterClass__c !== undefined){
            let meterClass = this.order.ServicePoint__r.MeterClass__c;
            let meterNum = meterClass.match(/\d+/)[0];
            if ((this.order.RecordType.DeveloperName === 'HDT_RT_Subentro'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_RiattivazioniNonMorose')
                && this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas'
                &&  meterNum >= 10) {
                this.showInviaModulistica = true;
            }
        }
    }

    typeVisibility(type){
        let result = true;
        if(this.order !== undefined && this.order.ServicePoint__c !== undefined){
            switch (type) {
                case 'ele':
                    result = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Ele';
                    break;
                case 'gas':
                    result = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
                    break
                default:
                    result = true;
                    break;
            }
        }
        return result;
    }

    processVisibility(process){
        let result = true;
        if(this.order.RecordType.DeveloperName !== undefined ){
            switch (process) {
                case 'ele':
                    result = this.order.RecordType.DeveloperName === 'HDT_RT_Ele';
                    break;
                case 'gas':
                    result = this.order.RecordType.DeveloperName === 'HDT_RT_Gas';
                    break
                default:
                    result = true;
                    break;
            }
        }
        return result;
    }

    // @Picchiri Qui vengono popolati i campi di Credit Check    
    applyCreditCheckLogic(fieldName){    
        console.log('applyCreditCheckLogic order----->' + JSON.parse(JSON.stringify(this.order)));
        if(this.order.RecordType.DeveloperName !== undefined ){
            switch (this.order.RecordType.DeveloperName) {
                case 'HDT_RT_Subentro':
                    if (fieldName === 'IncomingCreditCheckResult__c') {
                        return '';
                    }
                    else if (fieldName === 'OutgoingCreditCheckResult__c') {
                        return '';
                    }
                    break;
                case 'HDT_RT_Attivazione':
                    if (fieldName === 'IncomingCreditCheckResult__c') {
                        return '';
                    }
                    break;
                case 'HDT_RT_AttivazioneConModifica':
                    if (fieldName === 'IncomingCreditCheckResult__c') {
                        return '';
                    }
                    break;
                case 'HDT_RT_SwitchIn': 
                    if (fieldName === 'IncomingCreditCheckResult__c') {                        
                        return '';
                    }
                    if (fieldName === 'CreditCheckDescription__c') {                        
                        return '';
                    }                    
                    break;
                case 'HDT_RT_VAS':
                    if (fieldName === 'IncomingCreditCheckResult__c') {
                        return '';
                    }
                    break;
                case 'HDT_RT_Voltura':
                    if (fieldName === 'IncomingCreditCheckResult__c') {
                        return '';
                    }
                    break;
                default:
                    break;
            }
        }
    }

    getConfirmedSteps(){
        //EVERIS: MODIFICATO LAYOUT PER RENDERLO PIU FRIENDLY E AGGIUNTE SEZIONI
        this.confirmedSteps = this.availableStepsFirst.filter(section => (
        section.name !== 'reading'
        && section.name !== 'processVariables' 
        && section.name !== 'creditCheck' 
        && section.name !== 'dettaglioImpianto' 
        && section.name !== 'fatturazione' 
        && section.name !== 'datiPrecedenteIntestatario' 
        && section.name !== 'indirizzodiAttivazione' 
        && section.name !== 'indirizzoSpedizione' 
        && section.name !== 'ivaAccise'
        && section.name !== 'riepilogoDatiAmend'
        && section.name !== 'dateOrdine'));
    }

    getPendingSteps(){
        //EVERIS: MODIFICATO LAYOUT PER RENDERLO PIU FRIENDLY E AGGIUNTE SEZIONI
        console.log("PREFILTER:" + this.availableStepsFirst); 
        this.pendingSteps = this.availableStepsFirst.filter(section => (section.name === 'reading' 
        || section.name === 'processVariables'
        || section.name === 'creditCheck' 
        || section.name === 'dettaglioImpianto' 
        || section.name === 'fatturazione' 
        || section.name === 'datiPrecedenteIntestatario' 
        || section.name === 'indirizzodiAttivazione' 
        || section.name === 'indirizzoSpedizione' 
        || section.name === 'ivaAccise'
        || section.name === 'riepilogoDatiAmend'
        || section.name === 'dateOrdine'));
        this.availableSteps = this.pendingSteps; //did this because didn't want to replace available steps with pendingSteps as "availableSteps" is used in to many places
        console.log('PENDING HOLA:' + this.pendingSteps);
    }

    @api
    loadAccordion(){
        this.getConfirmedSteps();
        this.getPendingSteps();
        if(this.currentSection !== undefined){
            this.choosenSection = this.currentSection.name;
            this.activeSections = [this.choosenSection];
        }
    }

    getFirstStepName(){
        this.availableStepsFirst = this.fields.filter(section => section.processVisibility === true);
        this.loadAccordion();
        //EVERIS
        console.log('End loadAccordion callback');
        console.log('AvailabelSteps--> '+this.availableSteps);
        //EVERIS
        if(this.availableSteps.length > 0) {
            this.availableSteps[0].firstStep = true;
            this.availableSteps[this.availableSteps.length - 1].lastStep = true;
            this.lastStepNumber = this.availableSteps[this.availableSteps.length - 1].step;
            this.dispatchEvent(new CustomEvent('emitlaststep', {detail: {lastStepNumber: this.lastStepNumber}}));
            if (this.order.Step__c === 2) {
                this.currentSectionObjectApi = this.availableSteps[0].objectApiName;
                this.currentSectionRecordId = this.availableSteps[0].recordId;
                this.currentSection = this.availableSteps[0];
            } else {
                let currentStep = this.availableSteps.filter(section => section.step === this.order.Step__c);
                this.currentSectionObjectApi = currentStep[0].objectApiName;
                this.currentSectionRecordId = currentStep[0].recordId;
                this.currentSection = currentStep[0];
            }
        }
    }

    updateProcess(currentSectionIndex, nextSectionStep){
        //INIZIO SVILUPPI EVERIS
        console.log('isVolture: '+this.isVolture);
        console.log('isRetroactive: '+this.isRetroactive);
        console.log('isReading: '+this.isReading)
        let orderId = this.order.Id;
        //FINE SVILUPPI EVERIS
        //INSERITE NUOVE VARIABILI, IsRetroactive e IsReading solo in avanzamento di sezione.  
        updateProcessStep(
            {order: {Id: this.order.Id, Step__c: nextSectionStep, 
            ...this.sectionDataToSubmit,
            },
            isVolture: this.isVolture,
            isRetroactive: this.isRetroactive,
            isReading: this.isReading,
            readingDate: this.readingCustomerDate
        }).then(data =>{
            if(this.isVolture){
                getDates({recordId: orderId})
                    .then(data => {
                        let retroactiveDate = null;
                        let effectiveDate = data.EffectiveDate__c;
                        if(JSON.stringify(data).includes('RetroactiveDate__c')){
                            retroactiveDate = data.RetroactiveDate__c;
                        }
                        this.isRetroactive =  retroactiveDate != null;
                        this.disabledReadingDate = !this.isRetroactive;
                        console.log('#isRetroactive -> ' + this.isRetroactive);
                        console.log('#EffectiveDate -> ' + effectiveDate);
                        console.log('#RetroactiveDate -> ' + retroactiveDate);
                        console.log('#DisabledReading -> ' +this.disabledReadingDate);
                        if(this.isRetroactive){
                            this.readingCustomerDate = retroactiveDate;
                        } else {
                            this.readingCustomerDate = effectiveDate;
                        }
                    }).catch(error => {
                        console.log('#ErrorGetRecord -> '+JSON.stringify(error));
                    })
            }
            this.loading = false;
            //INIZIO SVILUPPI EVERIS
            //LA VARIABILE NEXT INDEX RIPORTA L'INDICE CORRETTO PER ANDARE AVANTI
            let nextIndex = this.availableSteps[currentSectionIndex + 1].step != nextSectionStep
            ? currentSectionIndex + 2
            : currentSectionIndex + 1
            //FINE SVILUPPI EVERIS
            this.currentSection = this.availableSteps[nextIndex];
            this.choosenSection = this.availableSteps[nextIndex].name;
            //INIZIO SVILUPPI EVERIS
            if(this.choosenSection === 'reading'){
                this.template.querySelector('c-hdt-self-reading').handleClick();
            }
            //FINE SVILUPPI EVERIS
            this.activeSections = [this.choosenSection];
            this.currentSectionObjectApi = this.availableSteps[nextIndex].objectApiName;
            this.currentSectionRecordId = this.availableSteps[nextIndex].recordId;
            this.sectionDataToSubmit = {};            
            this.dispatchEvent(new CustomEvent('refreshorderchild'));
            this.template.querySelector('c-hdt-accordion-with-click').refreshValues(this.order.Id);
        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext(event){
        this.loading = true;
        let currentSectionName = event.currentTarget.value;
        console.log("currentSectionName "+currentSectionName);
        let currentSection = this.availableSteps.filter(section => section.name === currentSectionName);
        let currentObjectApiName = currentSection[0].objectApiName;
        let currentRecordId = currentSection[0].recordId;
        let currentSectionIndex = this.availableSteps.findIndex(section => section.name === currentSectionName);
        //EVERIS AGGIUNTA LOGICA PER SEZIONE AUTOLETTURA
        let nextSectionStep =  currentSectionName === 'processVariables'
        ? (event.target.name === 'goReading' 
        ? this.availableSteps[currentSectionIndex + 1].step
        : this.availableSteps[currentSectionIndex + 2].step)
        : this.availableSteps[currentSectionIndex + 1].step;
        this.isReading = currentSectionName === 'reading';
        //EVERIS AGGIUNTA LOGICA PER SEZIONE AUTOLETTURA
        if(currentSectionName === 'indirizzodiAttivazione'){
            this.handleWrapAddressObjectAttivazione();
        }
        if(currentSectionName === 'indirizzoSpedizione'){
            this.handleWrapAddressObjectSpedizione();
        }
        if(currentSectionName === 'dettaglioImpianto'){
            if(this.template.querySelector("[data-id='SurfaceServed__c']") !== null 
                && this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                && this.typeVisibility('gas')
                && (this.template.querySelector("[data-id='SurfaceServed__c']").value === ''
                    || this.template.querySelector("[data-id='SurfaceServed__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Superficie Servita',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='WaiverRightAfterthought__c']") !== null 
                && (this.template.querySelector("[data-id='WaiverRightAfterthought__c']").value === ''
                    || this.template.querySelector("[data-id='WaiverRightAfterthought__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Rinuncia Diritto di Ripensamento',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='ConnectionMandate__c']") !== null 
                && (this.template.querySelector("[data-id='ConnectionMandate__c']").value === ''
                    || this.template.querySelector("[data-id='ConnectionMandate__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Mandato di connessione',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='AtecoCode__c']") !== null 
                && (this.template.querySelector("[data-id='AtecoCode__c']").value === ''
                    || this.template.querySelector("[data-id='AtecoCode__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Cod ISTAT Ateco',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='InstanceSelfCertification__c']") !== null 
                && (this.template.querySelector("[data-id='InstanceSelfCertification__c']").value === ''
                    || this.template.querySelector("[data-id='InstanceSelfCertification__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Autocert. Istanza',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='SelfCertificationConnection__c']") !== null 
                && (this.template.querySelector("[data-id='SelfCertificationConnection__c']").value === ''
                    || this.template.querySelector("[data-id='SelfCertificationConnection__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Autocert. contr connessione',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='PressureLevel__c']") !== null 
                && (this.template.querySelector("[data-id='PressureLevel__c']").value === ''
                    || this.template.querySelector("[data-id='PressureLevel__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Pressione fornitura',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' && this.template.querySelector("[data-id='WithdrawalClass__c']") !== null 
                && (this.template.querySelector("[data-id='WithdrawalClass__c']").value === ''
                    || this.template.querySelector("[data-id='WithdrawalClass__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Classe Profilo Prelievo',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='CommentForDL__c']") !== null 
                && (this.template.querySelector("[data-id='CommentForDL__c']").value === ''
                    || this.template.querySelector("[data-id='CommentForDL__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Note per il DL',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='ConnectionType__c']") !== null 
                && (this.template.querySelector("[data-id='ConnectionType__c']").value === ''
                    || this.template.querySelector("[data-id='ConnectionType__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Tipo di Connessione',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='RequestPhase__c']") !== null 
                && (this.template.querySelector("[data-id='RequestPhase__c']").value === ''
                    || this.template.querySelector("[data-id='RequestPhase__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Fase Richiesta',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='PhoneNumber__c']") !== null 
            && (this.template.querySelector("[data-id='PhoneNumber__c']").value === ''
                || this.template.querySelector("[data-id='PhoneNumber__c']").value === null)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Recapito Telefonico',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='ImplantType__c']") !== null && this.template.querySelector("[data-id='ImplantType__c']").value === '') {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Tipo Impianto',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
            if(this.template.querySelector("[data-id='CommoditySector__c']") !== null && this.template.querySelector("[data-id='CommoditySector__c']").value === 'Energia Elettrica' && (this.template.querySelector("[data-id='UseTypeEnergy__c']").value === null || this.template.querySelector("[data-id='UseTypeEnergy__c']").value === '')){
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Uso Energia',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
            }
        }
        if(currentSectionName === 'ivaAccise'){
            let errorMessageIvaAccise = '';
            let checkIsFlag = false;
            if(this.template.querySelector("[data-id='VATfacilitationFlag__c']") === true && this.template.querySelector("[data-id='VAT__c']").value === ''){
                errorMessageIvaAccise = 'Popolare IVA';
            }
            if(this.template.querySelector("[data-id='FacilitationExcise__c']") === true){
                if(this.template.querySelector("[data-id='ExciseEle__c']") !== null && this.template.querySelector("[data-id='ExciseEle__c']").value === ''){
                    errorMessageIvaAccise = 'Popolare Accise Agevolata Ele';
                }
                if(this.template.querySelector("[data-id='ExciseGAS__c']") !== null && this.template.querySelector("[data-id='ExciseGAS__c']").value === ''){
                    errorMessageIvaAccise = 'Popolare Accise Agevolata Gas';
                }
            }
            if(errorMessageIvaAccise !== ''){
                this.loading = false;
                const toastErrorMessageIvaAccise = new ShowToastEvent({
                    title: 'Errore',
                    message: errorMessageIvaAccise,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessageIvaAccise);
                return;
            }
            else{
                if(this.template.querySelector("[data-id='VATfacilitationFlag__c']") === true || this.template.querySelector("[data-id='FacilitationExcise__c']") === true){
                    let vatFacilitation = this.template.querySelector("[data-id='VATfacilitationFlag__c']");
                    let exciseFacilitation = this.template.querySelector("[data-id='FacilitationExcise__c']");
                    createActivityAccise({
                        flagAccise : this.template.querySelector("[data-id='FacilitationExcise__c']") === true,
                        flagVat : this.template.querySelector("[data-id='VATfacilitationFlag__c']") === true,
                        orderId : this.order.Id,
                        accountId : this.order.AccountId
                    }).then(response =>{
                        this.loading = false;
                        const toastErrorMessageIvaAccise = new ShowToastEvent({
                        title: 'Success',
                        message: 'Attivita Creata con Successo',
                        variant: 'success',
                        mode: 'sticky'
                        });
                        this.dispatchEvent(toastErrorMessageIvaAccise);
                    });
                }
            }
        }
        if(currentSectionName === 'fatturazione') {
           this.sectionDataToSubmit['AggregateBilling__c'] = this.template.querySelector("[data-id='AggregateBilling__c']").value;
        }
        if(currentSectionName === 'reading'){

            console.log('Inside reading condition');

            try{
                this.template.querySelector('c-hdt-self-reading').handleSaveButton();
            } catch(e){
                console.log('Inside Exception');
                console.log('Here');
                this.loading = false;
                return;
            }
            console.log('isSavedReading--> '+this.isSavedReading);
            
        }
        //f.defelice
        if((this.order.RecordType.DeveloperName=="HDT_RT_ConnessioneConAttivazione" || this.order.RecordType.DeveloperName=="HDT_RT_TemporaneaNuovaAtt") && currentSectionName === "dettaglioImpianto"){
            this.getQuoteType(currentSectionIndex, nextSectionStep);
            return;
        }

        this.updateProcess(currentSectionIndex, nextSectionStep);
    }

    async getQuoteType(currentSectionIndex, nextSectionStep){
        try{
            let wrap = await getQuoteTypeMtd({ord:
                {...this.order, 
                    ...this.sectionDataToSubmit, }
            });
            this.sectionDataToSubmit['QuotationType__c'] = wrap.quoteType;
            this.sectionDataToSubmit["OperationCode__c"] = wrap.quoteCode;
        }catch(e){
            console.log("Exception in getQuoteType "+e);
        }
        this.updateProcess(currentSectionIndex, nextSectionStep);
    }

    handleSectionToggle(event) {
        console.log('handleSecToggle '+this.choosenSection);
        this.activeSections = [this.choosenSection];
    }

    handlePrevious(event){
        this.loading = true;
        let currentSectionName = event.currentTarget.value;
        let currentSectionIndex = this.availableSteps.findIndex(section => section.name === currentSectionName);

        //INIZIO SVILUPPI EVERIS
        //LA VARIABILE nextIndex RIPORTA L'INDICE CORRETTO
        let nextIndex = this.availableSteps[currentSectionIndex - 1].name === 'reading'
        ? currentSectionIndex - 2
        : currentSectionIndex - 1
        //FINE SVILUPPI EVERIS 

        let previousSectionStep = this.availableSteps[nextIndex].step;

        updateProcessStep({order: {Id: this.order.Id, Step__c: previousSectionStep},isVolture:this.isVolture}).then(data =>{
            this.loading = false;
            this.currentSection = this.availableSteps[nextIndex];
            //EVERIS
            this.choosenSection = this.availableSteps[nextIndex].name;
            this.activeSections = [this.choosenSection];
            //EVERIS
            this.currentSectionObjectApi = this.availableSteps[nextIndex].objectApiName;
            this.currentSectionRecordId = this.availableSteps[nextIndex].recordId;
            this.sectionDataToSubmit = {};
            if(this.currentSection?.name==="creditCheck"){
                getRecordNotifyChange([{recordId: this.order.Id}]);
            }
            this.dispatchEvent(new CustomEvent('refreshorderchild'));

        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleFields(){
        this.fields = [
            {
                step: '',
                label: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' ? 'Riepilogo e Cliente Uscente' : 'Cliente Uscente',
                name: 'clienteUscente',
                objectApiName: 'Account',
                recordId: this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__r.Account__c : '',
                diffObjApi: 'Order',
                diffRecordId: this.order.Id,
                processVisibility: this.order.ServicePoint__c !== undefined && this.order.ServicePoint__r.Account__c !== this.order.AccountId && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'),
                data: [
                    {
                        'label': '',
                        'apiname': 'Subprocess__c',
                        'typeVisibility': this.order.RecordType.DeveloperName === 'HDT_RT_Voltura',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': '',
                        'diffObjApi' : 'Order'
                        },
                    {
                        'label': 'Nome',
                        'apiname': 'FirstName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome',
                        'apiname': 'LastName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Fiscale',
                        'apiname': 'FiscalCode__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Partita IVA',
                        'apiname': 'VATNumber__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Ragione sociale',
                        'apiname': 'Name',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 3,
                label: 'Credit check',
                name: 'creditCheck',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || (this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.ProcessType__c !== 'Switch in Ripristinatorio')
                || (this.isNotBillable)
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch'
                ,
                data: [
                    {
                        'label': 'Esito credit Check Entrante',
                        'apiname': 'IncomingCreditCheckResult__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.applyCreditCheckLogic('IncomingCreditCheckResult__c'),
                        'processVisibility': ''
                    },
                    {
                        'label': 'Esito credit Check Uscente',
                        'apiname': 'OutgoingCreditCheckResult__c',
                        'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && (!this.isNotBillable),
                        'required': false,
                        'disabled': true,
                        'value': this.applyCreditCheckLogic('OutgoingCreditCheckResult__c'),
                        'processVisibility': ''
                    },
                    {
                        'label': 'Descrizione esito',
                        'apiname': 'CreditCheckDescription__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.applyCreditCheckLogic('CreditCheckDescription__c'),
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 3,
                label: 'Variabili di Processo',
                name: 'processVariables',
                objectApiName: 'Order',
                recordId: this.order.Id,
                readingButton:true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura',
                data:[
                    {
                        'label': 'Tipo Voltura',
                        'apiname': 'VoltureType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '', 
                        'apiname': 'EffectiveDate__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '', 
                        'apiname': 'SignedDate__c',
                        'typeVisibility': this.order.ParentOrder__r.SignedDate__c != null,
                        'required': true,
                        'disabled': true,
                        'value': this.order.ParentOrder__r.SignedDate__c,
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'NotRegisteredMeterCase__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'AccountId',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'PhoneNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'Email__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'WithdrawalClass__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'AnnualConsumption__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'Market__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'SupplyType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'Commodity__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'ServicePointCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'ImplantType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },                    {
                        'label': '',
                        'apiname': 'SAPImplantCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': '',
                        'apiname': 'CustomerCategory__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 4,
                label: 'Autolettura',
                name: 'reading',
                objectApiName: '',
                recordId: '',
                isReading: true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
            },
            {
                step: 4,
                label: 'Dati precedente intestatario',
                name: 'datiPrecedenteIntestatario',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    {
                        'label': 'Nome precedente intestatario',
                        'apiname': 'PreviousHolderFirstName__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome precedente intestatario',
                        'apiname': 'PreviousHolderLastName__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'C.F. Precdente intestatario',
                        'apiname': 'PreviousHolderFiscalCode__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Ragione sociale precedente intestatario',
                        'apiname': 'PreviousHoldeCompanyName__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'P.Iva precedente intestatario',
                        'apiname': 'PreviousHolderVatNumber__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Voltura c/o VT',
                        'apiname': 'VolturaThirdTrader__c',
                        'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Voltura Tecnica',
                        'apiname': 'IsTechnicalTransfer__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 5,
                label: 'Dettaglio commodity',
                name: 'dettaglioImpianto',
                objectApiName: 'Order',
                recordId: this.order.Id,
                hasCalculateButton: this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica',
                hasCodiceAtecoButton: this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
               data: [
                {
                    'label': 'POD/PdR',
                    'apiname': 'ServicePointCodeFormula__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo Mercato',
                    'apiname': 'Market__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Setore merceologico',
                    'apiname': 'CommodityFormula__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Distributore',
                    'apiname': 'DistributorFormula__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Mercato di provenienza',
                    'apiname': 'MarketOrigin__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Impianto',
                    'apiname': 'ImplantTypeFormula__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Consumi Anno',
                    'apiname': 'AnnualConsumption__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza impegnata',
                    'apiname': 'PowerCommitted__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza disponibile',
                    'apiname': 'PowerAvailable__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza richiesta',
                    'apiname': 'PowerRequested__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tensione',
                    'apiname': 'VoltageLevel__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Disalimentabilità', //1
                    'apiname': 'Disconnectable__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Categoria disalimentabilità', //2
                    'apiname': 'DisconnectibilityType__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Recapito telefonico',
                    'apiname': 'DisconnectibilityPhone__c', //3
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                    'value': '',
                    'processVisibility': ''
                },

                {
                    'label': 'Data Inizio Connessione Temporanea',
                    'apiname': 'TemporaryConnectionStartDate__c', //3
                    'typeVisibility': this.typeVisibility('ele') &&  this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt',
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Data fine connessione temporanea',
                    'apiname': 'TemporaryConnectionEndDate__c', //3
                    'typeVisibility': this.typeVisibility('ele') &&  this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt',
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },

                {
                    'label': 'Ore di utilizzo',
                    'apiname': 'HoursOfUse__c', //3
                    'typeVisibility': this.typeVisibility('ele') &&  this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt',
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Conferma contratto cliente',
                    'apiname': 'ConfirmCustomerContract__c', //3
                    'typeVisibility': this.typeVisibility('ele') &&  (this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso' || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Residente all\'indirizzo di Fornitura',
                    'apiname': 'Resident__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Misuratore',
                    'apiname': 'MeterSN__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenzialità massima richiesta',
                    'apiname': 'MaxRequiredPotential__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Uso energia',
                    'apiname': 'UseTypeEnergy__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Categoria uso',
                    'apiname': 'UseCategory__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Classe prelievo',
                    'apiname': 'WithdrawalClass__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta',
                    'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Classe Contatore',
                    'apiname': 'MeterClass__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Località/Codice REMI',
                    'apiname': 'RemiCode__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                // {
                //     'label': 'ConnectionMandate__c',
                //     'apiname': 'ConnectionMandate__c',
                //     'typeVisibility': this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt'),
                //     'required': true,
                //     'disabled': false,
                //     'value': '',
                //     'processVisibility': ''
                // },
                // {
                //     'label': 'Autocert. contr connessione',
                //     'apiname': 'SelfCertificationConnection__c',
                //     'typeVisibility': this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt' ),
                //     'required': true,
                //     'disabled': false,
                //     'value': '',
                //     'processVisibility': ''
                // },
                // {
                //     'label': 'ConnectionType__c',
                //     'apiname': 'ConnectionType__c',
                //     'typeVisibility': this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt'),
                //     'required': false,
                //     'disabled': true,
                //     'value': '',
                //     'processVisibility': ''
                // },
                new fieldData('ConnectionType__c','ConnectionType__c', this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt'), false, true, '',''),
                new fieldData('Esecuzione Anticipata','RecessNotice__c',this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business', false, false, '',''),
                new fieldData('Rinuncia Diritto di Ripensamento','WaiverRightAfterthought__c', this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale', true, false, '',''),
                new fieldData('Società di vendita','SalesCompany__c', this.typeVisibility('both'), false, true, '',''),


                // {
                //     'label': 'Opzione richiesta',
                //     'apiname': 'RequestOption__c',
                //     'typeVisibility': this.typeVisibility('ele') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' && this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt' ),
                //     'required': true,
                //     // 'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_Subentro',
                //     'disabled': true,
                //     'value': '',
                //     'processVisibility': ''
                // },
                {
                    'label': 'Recapito telefonico',
                    'apiname': 'PhoneNumber__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Fase richiesta',
                    'apiname': 'RequestPhase__c',
                    'typeVisibility': this.typeVisibility('ele') && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta',
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Azione commerciale',
                    'apiname': 'CommercialAction__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Codice Ateco',
                    'apiname': 'AtecoCode__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Autocert Instanza',
                    'apiname': 'InstanceSelfCertification__c',
                    'typeVisibility': this.typeVisibility('ele') && this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta',
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'SAPImplantCode__c',
                    'apiname': 'SAPImplantCode__c',
                    'typeVisibility': this.typeVisibility('both') && (this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'SurfaceServed__c',
                    'apiname': 'SurfaceServed__c',
                    'typeVisibility': this.typeVisibility('gas') && (this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'),
                    'required': this.typeVisibility('gas') && this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Note per il DL',
                    'apiname': 'CommentForDL__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Convenzione/Associazione',
                    'apiname': 'ConventionAssociation__c',
                    'typeVisibility': this.typeVisibility('both') && (this.order.RecordType.DeveloperName !== 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName !== 'HDT_RT_TemporaneaNuovaAtt'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Esclusione dal deposito cauzionale',
                    'apiname': 'SecurityDepositExcluded__c',
                    'typeVisibility': this.typeVisibility('both') && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Pressione fornitura',
                    'apiname': 'PressureLevel__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Servizio Energetico',
                    'apiname': 'EnergyService__c',
                    'typeVisibility': this.typeVisibility('gas') && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo Apparechiatura',
                    'apiname': 'MeterType__c',
                    'typeVisibility': this.typeVisibility('ele') && (this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt') ,
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo Voltura',
                    'apiname': 'VoltureType__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },


               ]
            },

            {
                step: 5,
                label: 'Riepilogo Dati',
                name: 'riepilogoDatiAmend',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus' || this.isBillable,
                data: [
                    //constructor(
                    //    label, apiname, 
                    //    typeVisibility, 
                    //    required, disabled, processVisibility, value
                    // )
                    new fieldData(
                        'Numero Contratto','ConfirmCustomerContract__c',
                        this.order.ConfirmCustomerContract__c !== undefined, 
                        false, true, '',''
                    ), 
                    new fieldData(
                        'Uso energia','UseTypeEnergy__c', 
                        this.typeVisibility('both'), 
                        false, true, '',''
                    ),                  
                    new fieldData(
                        'POD/PDR','ServicePointCode__c', 
                        this.typeVisibility('both'),
                        false, true, '',''
                    ),  
                    new fieldData(
                        'Azione commerciale','CommercialAction__c',
                        this.typeVisibility('both'),
                        false, false, '',''
                    ), 
                    new fieldData('Tipo VAS','VASType__c', true, false, true, ''),
                    new fieldData(
                        'Sottotipo Vas','VASSubtype__c', 
                        this.typeVisibility('both'), 
                        false, true, '',''
                    ),
                    new fieldData('Categoria Cliente','CustomerCategory__c', true, false, true, ''),
                    new fieldData('Recapito Telefonico','PhoneNumber__c', true, false, true, ''),
                    new fieldData('Soc Vendita','SalesCompany__c', true, false, true, ''),

                    
                ]
            },
            {
                step: '',
                label: 'Analisi Consumi',
                name: 'analisiConsumi',
                objectApiName: 'OrderItem',
                recordId: this.analisiConsumi.Id !== undefined ? this.analisiConsumi.Id : '',//this.analisiConsumi.Id
                processVisibility: ( this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus' || this.isBillable ) && this.analisiConsumi.Id !== undefined,
                data: [

                    //constructor(
                    //    label, apiname, 
                    //    typeVisibility, 
                    //    required, disabled, processVisibility, value
                    // )
                    new fieldData(
                        'Proprietario','OwnerAC__c',
                        this.typeVisibility('both'), 
                        false, true, '',''
                    ), 
                    new fieldData(
                        'Tipo Casa','DwellingType__c', 
                        this.typeVisibility('both'), 
                        false, true, '',''
                    ),                  
                    new fieldData(
                        'N. Abitanti','OccupantsNumber__c', 
                        this.typeVisibility('both'),
                        false, true, '',''
                    ),
                    new fieldData(
                        'Mq. Casa','Surface__c',
                        this.typeVisibility('both'),
                        false, true, '',''
                    )
                ]
            },            
            {
                step: 7,
                label: 'Indirizzo di fornitura',
                name: 'indirizzoFornitura',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    //constructor(label, apiname, typeVisibility, required, disabled, processVisibility, value)
                    new fieldData('Comune','SupplyCity__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Via','SupplyStreetName__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Civico','SupplyStreetNumber__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Localita','SupplyPlace__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Provincia','SupplyState__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Cap','SupplyPostalCode__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Nazione','SupplyCityCode__c', this.typeVisibility('both'), true, true, '',''),                  
                    new fieldData('Codice Istat','SupplyCityCode__c', this.typeVisibility('both'), false, true, '','')
                ]
            },
            {
                step: '',
                label: this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale',
                name: 'indirizzoResidenzaOsedeLegale',
                objectApiName: 'Account',
                recordId: this.order.AccountId,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',

                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'BillingCity',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Via',
                        'apiname': 'BillingStreetName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'BillingStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'BillingPlace__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'BillingState',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'BillingPostalCode',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'BillingCountry',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'BillingCityCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: '',
                label: 'Fatturazione elettronica',
                name: 'fatturazioneElettronicaClienteNonResidenziale',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch')
                && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                data:[
                    {
                        'label': 'Codice Destinatario',
                        'apiname': 'SubjectCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'PEC Fatturazione Elettronica',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Modalità invio Fatturazione',
                        'apiname': 'ElectronicInvoicingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipo invio fattura XML',
                        'apiname': 'XMLType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIG',
                        'apiname': 'CIG__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CUP',
                        'apiname': 'CUP__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Data inizio Validità Codice Destinatario',
                        'apiname': 'SubjectCodeStartDate__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Note',
                        'apiname': 'PraxidiaNote__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 5,
                label: 'Dettaglio Dati',
                name: 'dettaglioImpianto',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.isNotBillable,
                data: [
                    //constructor(label, apiname, typeVisibility, required, disabled, processVisibility)
                    new fieldData('Ordine di riferimento','OrderReferenceNumber', true, false, true, ''),
                    new fieldData('Società di vendita','SalesCompany__c', true, false, true, ''),
                    new fieldData('Campagna','Campaign__c', true, false, true, ''),
                    new fieldData('Categoria Cliente','CustomerCategory__c', true, false, true, ''),
                    new fieldData('POD/PDR','ServicePointCode__c', true, false, true, ''),
                    new fieldData('Tipo VAS','VASType__c', true, false, true, ''),
                    new fieldData('Sottotipo VAS','VASSubtype__c', true, false, true, ''),
                    new fieldData('Recapito Telefonico','PhoneNumber__c', true, false, false, ''),
                    new fieldData('Azione Commerciale','CommercialAction__c', true, false, false, '')
                ]
            },
            {
                step: 6,
                label: 'Indirizzo di attivazione',
                name: 'indirizzodiAttivazione',
                hasAddrComp: true,
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.isNotBillable,
                data: [
                    
                ]
            },
            {
                step: 7,
                label: 'Indirizzo spedizione',
                name: 'indirizzoSpedizione',
                hasAddrComp: true,
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.isNotBillable,
                data: [
                    
                ]
            },
            {
                step: 8,
                label:'Fatturazione',
                name: 'fatturazione',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.isNotBillable || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.isBillable
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',

                data: [
                    {
                        'label': 'Modalità Invio Bolletta',
                        'apiname': 'BillSendMode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Email Invio Bolletta',
                        'apiname': 'InvoiceEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Email PEC invio Bolletta',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'SendCertifiedEmailConsentDate__c',
                        'apiname': 'SendCertifiedEmailConsentDate__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Destinatario Divergente',
                        'apiname': 'DivergentSubject__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Comune',
                        'apiname': 'BillingCity__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Stato',
                        'apiname': 'BillingCountry__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'BillingPlace__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'BillingProvince__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nome Via',
                        'apiname': 'BillingStreetName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'BillingStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CAP',
                        'apiname': 'BillingPostalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice ISTAT',
                        'apiname': 'BillingCityCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'AggregateBilling__c',
                        'apiname': 'AggregateBilling__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': false,
                        'value': 'Si',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 9,
                label:'Iva e accise',
                name: 'ivaAccise',
                objectApiName: 'Order',
                recordId: this.order.Id,
                hasIvaAcciseUploadButton: true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchInVolturaTecnica' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' 
                                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    {
                        'label': 'Flag Agevolazione IVA',
                        'apiname': 'VATfacilitationFlag__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Flag Accise Agevolata',
                        'apiname': 'FacilitationExcise__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta',
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'IVA',
                        'apiname': 'VAT__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': this.order.Vat__c,
                        'processVisibility': ''
                    },
                    {
                        'label': 'Accise Agevolata Ele',
                        'apiname': 'ExciseEle__c',
                        'typeVisibility': this.typeVisibility('ele'),
                        'required': false,
                        'disabled': true,
                        'value': this.order.ExciseEle__c,
                        'processVisibility': ''
                    },
                    {
                        'label': 'Accise Agevolata Gas',
                        'apiname': 'ExciseGAS__c',
                        'typeVisibility': this.typeVisibility('gas'),
                        'required': false,
                        'disabled': false,
                        'value': this.order.ExciseGas__c,
                        'processVisibility': ''
                    },
                ]
            },
            {
                step: '',
                label: 'Metodo Firma e Canale Invio',
                name: 'metodoFirma',
                objectApiName: 'Order',
                recordId: this.order.ParentOrder__c,
                processVisibility: ( this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus' || this.isBillable ),
                data: [

                    //constructor(
                    //    label, apiname, 
                    //    typeVisibility, 
                    //    required, disabled, processVisibility, value
                    // )
                    new fieldData(
                        'Metodo Firma','SignatureMethod__c',
                        this.typeVisibility('both'), 
                        false, true, '',''
                    ), 
                    new fieldData(
                        'Invio Doc','DocSendingMethod__c', 
                        this.typeVisibility('both'), 
                        false, true, '',''
                    ),                  
                    new fieldData(
                        'Data Firma','SignedDate__c', 
                        this.typeVisibility('both'),
                        false, true, '', this.order.ParentOrder__r.SignedDate__c
                    )
                  
                ]
            },  
            {
                step: '',
                label: 'Metodo pagamento',
                name: 'metodoPagamento',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.isNotBillable || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.isBillable
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch',
                data: [
                    {
                        'label': 'Modalità di Pagamento',
                        'apiname': 'PaymentMode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'IBAN Estero',
                        'apiname': 'IbanIsForeign__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Paese',
                        'apiname': 'IbanCountry__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Numeri di Controllo',
                        'apiname': 'IbanCIN_IBAN__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIN',
                        'apiname': 'IbanCIN__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'ABI',
                        'apiname': 'IbanABI__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CAB',
                        'apiname': 'IbanCAB__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Numero conto corrente',
                        'apiname': 'IbanCodeNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipologia Intestatario',
                        'apiname': 'SignatoryType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Fiscale intestatario c/c',
                        'apiname': 'BankAccountSignatoryFiscalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nome Intestatario c/c',
                        'apiname': 'BankAccountSignatoryFirstName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome Intestario c/c',
                        'apiname': 'BankAccountSignatoryLastName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 10,
                label: 'Date ordine',
                name: 'dateOrdine',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta') && this.order.ParentOrder__r.ContractSigned__c,
                data: [
                    {
                        'label': 'Data Firma',
                        'apiname': 'SignedDate__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.order.ParentOrder__r.SignedDate__c,
                        'processVisibility': ''
                    },
                    {
                        'label': 'Data Massima Ripensamento',
                        'apiname': 'MaxAfterthoughtDate__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Attivazione Posticipata',
                        'apiname': 'IsActivationDeferred__c',
                        'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Data decorrenza',
                        'apiname': 'EffectiveDate__c',
                        'typeVisibility': this.order.IsActivationDeferred__c,
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                lastStep: true,
                step: '',
                label: 'Metodo firma canale invio',
                name: 'metodoFirmaCanaleInvio',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.isNotBillable || (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioUso'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch'),
                data: [
                    {
                        'label': 'Metodo firma',
                        'apiname': 'SignatureMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Invio doc',
                        'apiname': 'DocSendingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            }
        ];
    }

    handleWrapAddressObjectAttivazione(){
        this.wrapAddressObjectAttivazione = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        if(this.sectionDataToSubmit['ActivationStreetName__c'] != this.wrapAddressObjectAttivazione['Via']){
            this.sectionDataToSubmit['ActivationStreetName__c'] = this.wrapAddressObjectAttivazione['Via'];
        }
        if(this.sectionDataToSubmit['ActivationCity__c'] != this.wrapAddressObjectAttivazione['Comune']){
            this.sectionDataToSubmit['ActivationCity__c'] = this.wrapAddressObjectAttivazione['Comune'];
        }
        if(this.sectionDataToSubmit['ActivationPostalCode__c'] != this.wrapAddressObjectAttivazione['CAP']){
            this.sectionDataToSubmit['ActivationPostalCode__c'] = this.wrapAddressObjectAttivazione['CAP'];
        }
        if(this.sectionDataToSubmit['ActivationCountry__c'] != this.wrapAddressObjectAttivazione['Stato']){
            this.sectionDataToSubmit['ActivationCountry__c'] = this.wrapAddressObjectAttivazione['Stato'];
        }
        if(this.sectionDataToSubmit['ActivationProvince__c'] != this.wrapAddressObjectAttivazione['Provincia']){
            this.sectionDataToSubmit['ActivationProvince__c'] = this.wrapAddressObjectAttivazione['Provincia'];
        }
        if(this.sectionDataToSubmit['ActivationStreetNumberExtension__c'] != this.wrapAddressObjectAttivazione['Estens.Civico']){
            this.sectionDataToSubmit['ActivationStreetNumberExtension__c'] = this.wrapAddressObjectAttivazione['Estens.Civico'];
        }
        if(this.sectionDataToSubmit['ActivationStreetNumber__c'] != this.wrapAddressObjectAttivazione['Civico']){
            this.sectionDataToSubmit['ActivationStreetNumber__c'] = this.wrapAddressObjectAttivazione['Civico'];
        }
    }

    handleWrapAddressObjectAttivazioniReverse(){
        if(this.order['ActivationStreetName__c'] != undefined){
            this.wrapAddressObjectAttivazione['Via'] = this.order['ActivationStreetName__c'];
        }
        if(this.order['ActivationCity__c'] != undefined){
            this.wrapAddressObjectAttivazione['Comune'] = this.order['ActivationCity__c'];
        }
        if(this.order['ActivationPostalCode__c'] != undefined){
            this.wrapAddressObjectAttivazione['CAP'] = this.order['ActivationPostalCode__c'];
        }
        if(this.order['ActivationCountry__c'] != undefined){
            this.wrapAddressObjectAttivazione['Stato'] = this.order['ActivationCountry__c'];
        }
        if(this.order['ActivationProvince__c'] != undefined){
            this.wrapAddressObjectAttivazione['Provincia'] = this.order['ActivationProvince__c'];
        }
        if(this.order['ActivationStreetNumberExtension__c'] != undefined){
            this.wrapAddressObjectAttivazione['Estens.Civico'] = this.order['ActivationStreetNumberExtension__c'];
        }
        if(this.order['ActivationStreetNumber__c'] != undefined){
            this.wrapAddressObjectAttivazione['Civico'] = this.order['ActivationStreetNumber__c'];
        }
        this.template.querySelector("c-hdt-target-object-address-fields").getInstanceWrapObjectBilling(this.wrapAddressObjectAttivazione);
    }

    handleWrapAddressObjectSpedizione(){
        this.wrapAddressObjectSpedizione = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        if(this.sectionDataToSubmit['ShippingStreetName__c'] != this.wrapAddressObjectSpedizione['Via']){
            this.sectionDataToSubmit['ShippingStreetName__c'] = this.wrapAddressObjectSpedizione['Via'];
        }
        if(this.sectionDataToSubmit['ShippingCity__c'] != this.wrapAddressObjectSpedizione['Comune']){
            this.sectionDataToSubmit['ShippingCity__c'] = this.wrapAddressObjectSpedizione['Comune'];
        }
        if(this.sectionDataToSubmit['ShippingPostalCode__c'] != this.wrapAddressObjectSpedizione['CAP']){
            this.sectionDataToSubmit['ShippingPostalCode__c'] = this.wrapAddressObjectSpedizione['CAP'];
        }
        if(this.sectionDataToSubmit['ShippingCountry__c'] != this.wrapAddressObjectSpedizione['Stato']){
            this.sectionDataToSubmit['ShippingCountry__c'] = this.wrapAddressObjectSpedizione['Stato'];
        }
        if(this.sectionDataToSubmit['ShippingProvince__c'] != this.wrapAddressObjectSpedizione['Provincia']){
            this.sectionDataToSubmit['ShippingProvince__c'] = this.wrapAddressObjectSpedizione['Provincia'];
        }
        if(this.sectionDataToSubmit['ShippingStreetNumberExtension__c'] != this.wrapAddressObjectSpedizione['Estens.Civico']){
            this.sectionDataToSubmit['ShippingStreetNumberExtension__c'] = this.wrapAddressObjectSpedizione['Estens.Civico'];
        }
        if(this.sectionDataToSubmit['ShippingStreetNumber__c'] != this.wrapAddressObjectSpedizione['Civico']){
            this.sectionDataToSubmit['ShippingStreetNumber__c'] = this.wrapAddressObjectSpedizione['Civico'];
        }
    }

    handleWrapAddressObjectSpedizioneReverse(){
        if(this.order['ShippingStreetName__c'] != undefined){
            this.wrapAddressObjectSpedizione['Via'] = this.order['ShippingStreetName__c'];
        }
        if(this.order['ShippingCity__c'] != undefined){
            this.wrapAddressObjectSpedizione['Comune'] = this.order['ShippingCity__c'];
        }
        if(this.order['ShippingPostalCode__c'] != undefined){
            this.wrapAddressObjectSpedizione['CAP'] = this.order['ShippingPostalCode__c'];
        }
        if(this.order['ShippingCountry__c'] != undefined){
            this.wrapAddressObjectSpedizione['Stato'] = this.order['ShippingCountry__c'];
        }
        if(this.order['ShippingProvince__c'] != undefined){
            this.wrapAddressObjectSpedizione['Provincia'] = this.order['ShippingProvince__c'];
        }
        if(this.order['ShippingStreetNumberExtension__c'] != undefined){
            this.wrapAddressObjectSpedizione['Estens.Civico'] = this.order['ShippingStreetNumberExtension__c'];
        }
        if(this.order['ShippingStreetNumber__c'] != undefined){
            this.wrapAddressObjectSpedizione['Civico'] = this.order['ShippingStreetNumber__c'];
        }
        this.template.querySelector("c-hdt-target-object-address-fields").getInstanceWrapObjectBilling(this.wrapAddressObjectSpedizione);
    }

    
    connectedCallback(){
        //EVERIS
        console.log('Details Callback Start');
        //EVERIS

        this.title = 'Processo di ' + this.order.RecordType.Name;
        this.isAccountResidential = this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale';
        this.handleShowModuloInformativo();
        this.handleShowDelibera40();
        this.handleShowInviaModulistica();
        this.handleFields();

        // @Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
        if((this.selectedProcess === 'HDT_RT_VAS' && !this.order.IsBillableVas__c && (this.order.OrderReferenceNumber == null || this.order.OrderReferenceNumber === undefined) && (this.order.ContractReference__c == null || this.order.ContractReference__c === undefined)) || this.selectedProcess === 'HDT_RT_Voltura' ||this.selectedProcess === 'HDT_RT_Subentro' || this.selectedProcess === 'HDT_RT_AttivazioneConModifica' || (this.selectedProcess === 'HDT_RT_SwitchIn' && this.order.ProcessType__c != 'Switch in Ripristinatorio') || this.selectedProcess === 'HDT_RT_ConnessioneConAttivazione' || this.selectedProcess === 'HDT_RT_TemporaneaNuovaAtt'){
            this.retryEsitiCreditCheck();
        }        

        this.applyCreditCheckLogic(); 
        this.availableStepsFirst = this.fields.filter(section => section.processVisibility === true);
        console.log("********AVAIBLESTEP:" + JSON.stringify(this.availableStepsFirst));
        this.getFirstStepName();
        this.loadAccordion();

       //EVERIS
        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
            this.isVolture = this.order.RecordType.DeveloperName === 'HDT_RT_Voltura';
            console.log('IsVolture--> '+this.isVolture);
            console.log('ConfirmedSteps--> '+JSON.stringify(this.confirmedSteps));
            console.log('Details Callback End');
            console.log('CommoditySector -> ' + this.order.ServicePoint__r.CommoditySector__c)
            this.readingDisabled = (this.order.ServicePoint__r.CommoditySector__c.localeCompare('Energia Elettrica') === 0);
            console.log('ReadingDisabled? ->' +this.readingDisabled);
        }
        //EVERIS
        console.log('CheckVariables');
    }

    renderedCallback(){
        if(this.currentSection.name === 'indirizzodiAttivazione'){
            this.handleWrapAddressObjectAttivazioniReverse();
        }
        if(this.currentSection.name === 'indirizzoSpedizione'){
            this.handleWrapAddressObjectSpedizioneReverse();
        }
    }

    handleDocAnticipata(event){
        var buttonLabel = event.target.label;
        var tipoDoc = '';
        if(buttonLabel=='Modulo informativo'){
            tipoDoc = 'MODULISTICA_NO_B12';
        }else if(buttonLabel=='Delibera 40'){
            tipoDoc = 'DELIBERA_40';
        }else{
            tipoDoc = 'MODULISTICA_B12';
        }
        var formParams = {     
            mode : 'Print',
            Archiviato : 'Y',
            TipoPlico:tipoDoc,
            sendMode:'Sportello'
        };
        sendAdvanceDocumentation({
            recordId: this.order.Id,
            context: 'DocumentazioneAnticipata',
            formParams: JSON.stringify(formParams)
        }).then(result => {
            const event = new ShowToastEvent({
                title: 'Successo',
                message: 'Documentazione inviata',
                variant: 'success',
            });
            this.dispatchEvent(event);
        }).catch(error => {
            const event = new ShowToastEvent({
                title: 'Attenzione',
                message: 'Non è stato possibile inviare la documentazione al cliente',
                variant: 'error',
            });
            this.dispatchEvent(event);
            console.error(error);
        });
    }

    retryEsitiCreditCheck(){        
        let self = this;
        self.loading = true;
        setTimeout(function(){
            retrieveOrderCreditCheck({idOrder: self.order.Id})
            .then(result=>{
                console.log(JSON.parse(JSON.stringify(result)));
                for(var i = 0; i < self.fields.length; i++){
                    console.log(self.fields[i].name)
                    if(self.fields[i].name == 'creditCheck'){
                        let creditCheckData = self.fields[i].data
                        for(let j = 0;  j < creditCheckData.length; j++){
                            if(creditCheckData[j].apiname == 'IncomingCreditCheckResult__c'){
                                creditCheckData[j].value = result['IncomingCreditCheckResult__c']
                            }
                            else if(creditCheckData[j].apiname == 'OutgoingCreditCheckResult__c'){
                                creditCheckData[j].value = result['OutgoingCreditCheckResult__c'];
                            }
                            else if (creditCheckData[j].apiname == 'CreditCheckDescription__c'){
                                creditCheckData[j].value = result['CreditCheckDescription__c'];
                            }
                        }
                        break;
                    }
                }
                self.loading = false
            })
            .catch(error=>{console.log(error)})
        }, 3000)
    }

    handleUpdateCodAtecoEvent(event){
        this.template.querySelector("[data-id='AtecoCode__c']").value = event.detail;
    }
}