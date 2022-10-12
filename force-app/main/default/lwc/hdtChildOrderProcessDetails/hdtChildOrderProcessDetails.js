import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateProcessStep from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.updateProcessStep';
import init from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.init';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import  voltureEffectiveDateCheck from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.voltureEffectiveDateCheck';
import getDates from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.getDates';
import getQuoteTypeMtd from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd';
import isPreventivo from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.isPreventivo';
import retrieveOrderCreditCheck from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.retrieveOrderCreditCheck';
import getReadingId from '@salesforce/apex/HDT_LC_SelfReading.getReadingId';
import isAfterthoughtDaysZero from '@salesforce/apex/HDT_UTL_ProcessDateManager.isAfterthoughtDaysZero';
import checkPermissionSet from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.checkPermissionSet';
import {handleSections, equalsIgnoreCase, safeStr} from 'c/hdtChildOrderProcessDetailsUtl';

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
    @api isRepeatedStep;
    wrapAddressObjectAttivazione = {};
    wrapAddressObjectSpedizione = {};
    @api analisiConsumi;
    acceptedFormatsIvaAcciseUpload = ['.pdf', '.png'];
    @track lastStepData = {};
    @track isNoDayAfterthought = false;
    @track permissionFlag = true;
    loginChannel;
    closeAttachmentEvent;
    @track additionalAttachments;

    get orderWithData(){
       console.log('#Order With Data >>> ' +JSON.stringify(this.sectionDataToSubmit));
       return {...this.order, ...this.sectionDataToSubmit};
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

    get isCreditCheckVisible(){
        return this.order.Step__c === 2;
    }

    //INIZIO SVILUPPI EVERIS
    @track readingCustomerDate;
    @track disabledReadingDate;
    @track isRetroactive = false;
    @track isSavedReading;
    @track outputFieldObj = {};
    @track isVolture;
    @track isReading;
    @track resumeFromDraftReading = false;
    @track readingDisabled = false;
    @track currentSectionName;
    sysdate(){
        var sysdateIso = new Date().toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return sysdateIso.substr(0, sysdateIso.indexOf('T'));
    }
    //FINE SVILUPPI EVERIS

    handleSectionDataToSubmitCollection(event){
        if(event.target.fieldName === 'EffectiveDate__c' && this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
                console.log('EffectiveDateValue -> ' + event.target.value);
                voltureEffectiveDateCheck({effectiveDate: event.target.value})
                    .then(result => {
                        console.log('Result -> '+result);
                        if(result === 1){
                            this.readingDisabled = true;
                        } else {
                            this.readingDisabled = false;
                        }
                    }).catch(error => {
                        console.log('Error -> ' +error);
                    });
            
        }
        if(event.target.fieldName !== undefined){
            this.sectionDataToSubmit[event.target.fieldName] = event.target.value;
        }
        if(event.target.name !== undefined){
            this.sectionDataToSubmit[event.target.name] = event.target.value;
        }

        const DynamicOnChange = this.pendingSteps[event.target.getAttribute('data-section-index')]?.data?.[event.target.getAttribute('data-field-index')]?.changeFunction;
        if(DynamicOnChange && DynamicOnChange instanceof Function ){
            DynamicOnChange.call(this, event);
        }

        /*  # Le logiche degli eventi onchange dei singoli campi sono configurabili direttamente nel JSON del wizard

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
        } */
        let draftData = this.sectionDataToSubmit;
        draftData.Id = this.currentSectionRecordId;
        if(this.lastStepNumber === this.currentSection.step) {
            this.lastStepData = draftData;
        }

        if(draftData.AdditionalAttachments__c){
            this.additionalAttachments = draftData.AdditionalAttachments__c;
            console.log('data AdditionalAttachments__c '+ draftData.AdditionalAttachments__c);
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

    landSelected(event){
        this.landRedistrySelected=true;
    }

    handleShowInviaModulistica(caliber = ''){
        if(this.order.ServicePoint__c !== undefined && this.order.ServicePoint__r.MeterClass__c !== undefined){
            let meterClass = caliber !== '' ? caliber : this.order.ServicePoint__r.MeterClass__c;
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
                    break;
                case 'tari':
                    result = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Ambiente';
                    break;
                case 'acqua':
                    result = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Acqua';
                    break;
                default:
                    result = true;
                    break;
            }
        }
        return result;
    }

    rateCategoryVisibility(evaluationRateCategories)
    {
        let evaluationType = evaluationRateCategories.evaluationType;
        let rateCategories = evaluationRateCategories.rateCategories;

        // !Acqua, then if 'required', set 'notrequired', if 'visible/notvisible', set 'visible'
        if(this.order.ServicePoint__r.RecordType.DeveloperName !== 'HDT_RT_Acqua' || !Array.isArray(rateCategories) ) return evaluationType !== 'required';
        
        // case Acqua
        let rateCategory = this.order.RateCategory__c
        let result = evaluationType === 'notvisible';
        for(let rate of rateCategories)
        {
            if(rate === rateCategory && evaluationType === 'visible') result = true;
            if(rate === rateCategory && evaluationType === 'notvisible') result = false;
            if(rate === rateCategory && evaluationType === 'required') result = true;
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

    handleSectionDiffDataToSubmitCollection(){
        return;
    }

    getConfirmedSteps(){
        this.confirmedSteps = this.availableStepsFirst.filter(section => (
        section.name !== 'reading'
        && section.name !== 'processVariables' 
        && section.name !== 'variabiliDiProcesso'
        && section.name !== 'datiSottoscrittore'
        && section.name !== 'datiCatastali'
        && section.name !== 'Switchout' 
        && section.name !== 'dettaglioImpianto' 
        && section.name !== 'fatturazione' 
        && section.name !== 'datiPrecedenteIntestatario' 
        && section.name !== 'indirizzodiAttivazione' 
        && section.name !== 'indirizzoSpedizione' 
        && section.name !== 'ivaAccise'
        && section.name !== 'riepilogoDatiAmend'
        && section.name !== 'dateOrdine'
        && section.name !== 'analisiConsumi'));
    }

    getPendingSteps(){
        console.log("PREFILTER:" + this.availableStepsFirst); 
        this.pendingSteps = this.availableStepsFirst.filter(section => (section.name === 'reading' 
        || section.name === 'processVariables'
        || section.name === 'variabiliDiProcesso'
        || section.name === 'datiSottoscrittore'
        || section.name === 'datiCatastali'
        || section.name === 'Switchout'
        || section.name === 'dettaglioImpianto' 
        || section.name === 'fatturazione' 
        || section.name === 'datiPrecedenteIntestatario' 
        || section.name === 'indirizzodiAttivazione' 
        || section.name === 'indirizzoSpedizione' 
        || section.name === 'ivaAccise'
        || section.name === 'riepilogoDatiAmend'
        || section.name === 'dateOrdine'
        || section.name === 'analisiConsumi'));
        this.availableSteps = this.pendingSteps; //did this because didn't want to replace available steps with pendingSteps as "availableSteps" is used in to many places
        console.log('PENDING HOLA:' + JSON.stringify(this.pendingSteps));
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

        console.log('End loadAccordion callback');
        console.log('AvailabelSteps--> '+this.availableSteps);
        
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
        console.log('isVolture: '+this.isVolture);
        console.log('isRetroactive: '+this.isRetroactive);
        console.log('isReading: '+this.isReading);
        console.log('CurrentSectionName: '+this.currentSectionName);
        console.log('isUpdateStep: '+ this.isVolture === true && this.currentSectionName === 'processVariables');
        let orderId = this.order.Id;
        if(this.sectionDataToSubmit["Id"] !== undefined && this.sectionDataToSubmit["Id"] === this.analisiConsumi.Id)
        {
            this.sectionDataToSubmit["OrderId"] = orderId;
            this.sectionDataToSubmit["Description"] = nextSectionStep;
            console.log('#Section ANalisi Consumi >>> ' + JSON.stringify(this.sectionDataToSubmit));
        }
        //INSERITE NUOVE VARIABILI, IsRetroactive e IsReading solo in avanzamento di sezione.  
        updateProcessStep(
            {order: {Id: orderId, Step__c: nextSectionStep, 
            ...this.sectionDataToSubmit,
            },
            isVolture: this.isVolture,
            isRetroactive: this.isRetroactive,
            isReading: this.isReading,
            isUpdateStep: this.isVolture === true && this.currentSectionName === 'processVariables',
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
            //LA VARIABILE NEXT INDEX RIPORTA L'INDICE CORRETTO PER ANDARE AVANTI
            let nextIndex = this.availableSteps[currentSectionIndex + 1].step != nextSectionStep
            ? currentSectionIndex + 2
            : currentSectionIndex + 1
            this.currentSection = this.availableSteps[nextIndex];
            this.choosenSection = this.availableSteps[nextIndex].name;
            if(this.choosenSection === 'reading'){
                this.template.querySelector('c-hdt-self-reading').handleClick();
            }
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

    @api
    getFieldsForEstimatedCost()
    {
        let wrpOrder = {};
        wrpOrder["Id"] = this.order.Id;
        wrpOrder["RecordTypeId"] = this.order.RecordTypeId;
        wrpOrder["ConnectionType__c"] = this.checkFieldAvailable("ConnectionType__c") !== '' ? this.checkFieldAvailable("ConnectionType__c") : this.order["ConnectionType__c"];
        wrpOrder["RequestPhase__c"] = this.checkFieldAvailable("RequestPhase__c") !== '' ? this.checkFieldAvailable("RequestPhase__c") : this.order["RequestPhase__c"];
        wrpOrder["ProcessCode__c"] = this.order["ProcessCode__c"];
        wrpOrder["DistributorFormula__c"] = this.order["DistributorFormula__c"];
        wrpOrder["PowerRequested__c"] = this.checkFieldAvailable("PowerRequested__c") !== '' ? this.checkFieldAvailable("PowerRequested__c") : this.order["PowerRequested__c"];
        wrpOrder["PowerAvailable__c"] = this.checkFieldAvailable("PowerAvailable__c") !== '' ? this.checkFieldAvailable("PowerAvailable__c") : this.order["PowerAvailable__c"];
        wrpOrder["VoltageLevel__c"] = this.checkFieldAvailable("VoltageLevel__c") !== '' ? this.checkFieldAvailable("VoltageLevel__c") : this.order["VoltageLevel__c"];
        wrpOrder["PowerCommitted__c"] = this.checkFieldAvailable("PowerCommitted__c") !== '' ? this.checkFieldAvailable("PowerCommitted__c") : this.order["PowerCommitted__c"];
        wrpOrder["UseTypeEnergy__c"] = this.checkFieldAvailable("UseTypeEnergy__c") !== '' ? this.checkFieldAvailable("UseTypeEnergy__c") : this.order["UseTypeEnergy__c"];
        this.template.querySelector('c-hdt-calculate-estimated-cost').order = wrpOrder;
        this.template.querySelector('c-hdt-calculate-estimated-cost').getQuoteType();
    }

    checkFieldAvailable(fieldApiName, isRequired = false)
    {
        console.log('#fieldName >>> ' + fieldApiName);
        if(this.template.querySelector(`[data-id=${fieldApiName}]`) !== null)
        {
            if((this.template.querySelector(`[data-id=${fieldApiName}]`).value === ''|| this.template.querySelector(`[data-id=${fieldApiName}]`).value === null))
            {
                if(isRequired === true && this.template.querySelector(`[data-id=${fieldApiName}]`).required === true)
                {
                    return '';
                }
                else
                {
                    return 'non obbligatorio';
                }
            }
            else
            {
                return this.template.querySelector(`[data-id=${fieldApiName}]`).value;
            }
        }
        else
        {
            return 'non obbligatorio';
        }
        
    }

    showMessage(title,message,variant)
    {
        this.loading = false;
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
    this.dispatchEvent(toastErrorMessage);
    }

    handleNext(event){
        this.loading = true;
        let currentSectionName = event.currentTarget.value;
        this.currentSectionName = currentSectionName;
        console.log('currentSectionName '+currentSectionName);
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

        const sectionNextActions = this.pendingSteps[event.target.getAttribute('data-section-index')]?.nextActions;
        if(sectionNextActions && sectionNextActions instanceof Function ){
            if(sectionNextActions(event)) return;//Azioni automatiche da eseguire definite nel JSON del Wizard
        }
        
        console.log('currentSectionName '+currentSectionName);

        //EVERIS AGGIUNTA LOGICA PER SEZIONE AUTOLETTURA
        if(currentSectionName === 'reading'){
            let readingComponent = this.template.querySelector('c-hdt-self-reading');
            getReadingId({objectName:'Order',objectId:this.order.Id, commodity:this.order.CommodityFormula__c})
            .then(data => 
                {
                    console.log('# ReadingId >>> ' + data);
                    this.resumeFromDraftReading = data !== null && data !== undefined;
                    readingComponent.resumedFromDraft = this.resumeFromDraftReading;
                    console.log('# Resume From Draft >>> ' + this.resumeFromDraftReading);
                    console.log('# Child Resume From Draft >>> ' + readingComponent.resumedFromDraft);
                    readingComponent.handleSaveButton();
                    this.isSavedReading = false;
                    readingComponent.isSaved = false;
                    console.log('# Child Resume From Draft After>>> ' + this.resumeFromDraftReading);
                    this.updateProcess(currentSectionIndex, nextSectionStep);
                })
            .catch(error => 
                {
                    console.log('selfreading entering error message');
                    this.loading = false;
                    return;
                })
            
        }
        else
        {
            if(currentSectionName === 'indirizzodiAttivazione'){
                if(this.isCorrectlyFilled()){
                    this.handleWrapAddressObjectAttivazione();
                }else{
                    this.loading = false;                        
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare i campi obbligatori',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    return;
                }
            }
            if(currentSectionName === 'indirizzoSpedizione'){
                if(this.isCorrectlyFilled()){
                    this.handleWrapAddressObjectSpedizione();
                }else{
                    this.loading = false;                        
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare i campi obbligatori',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    return;
                }
            }
            if(currentSectionName === 'processVariables'){
                if(this.checkFieldAvailable('MaxRequiredPotential__c', true) === '' && this.typeVisibility('gas'))
                {
                    this.showMessage('Errore', 'Popolare il campo Potenzialita Massima Richiesta', 'error');
                    return;
                }
            }
            console.log('currentSectionName '+currentSectionName);
            if(currentSectionName === 'dettaglioImpianto'){
                console.log('inside '+currentSectionName);
                if( this.template.querySelector("[data-id='RealEstateUnit__c']") !== null && this.typeVisibility('acqua') && this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' )
                {
                    if( this.template.querySelector("[data-id='ImplantType__c']").value.includes('Promiscuo') && this.template.querySelector("[data-id='RealEstateUnit__c']").value < 2 )
                    {
                        this.showMessage('Errore', 'In caso di Tipo Impianto Promiscuo è necessario che il numero delle Unita Immobiliari sia maggiore di 1', 'error');
                        return;
                    }
                    if( !this.template.querySelector("[data-id='ImplantType__c']").value.includes('Promiscuo') && this.template.querySelector("[data-id='RealEstateUnit__c']").value > 1 )
                    {
                        this.showMessage('Errore', 'Per indicare un numero di Unita Immobiliari maggiore di 1 è necessario modificare il Tipo Impianto in Promiscuo', 'error');
                        return;
                    }
                }
                if( this.checkFieldAvailable('EffectiveDate__c', true) === '' && this.typeVisibility('acqua'))
                {
                    this.showMessage('Errore', 'Popolare il campo Data Decorrenza', 'error');
                    return;
                }
                if( this.checkFieldAvailable('MaxRequiredPotential__c', true) === '' && this.typeVisibility('gas'))
                {
                    this.showMessage('Errore', 'Popolare il campo Potenzialita Massima Richiesta', 'error');
                    return;
                }
                if(this.template.querySelector("[data-id='SurfaceServed__c']") !== null 
            
                    && 
                    this.typeVisibility('gas') 
                    && 
                    (this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' || this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta')
                    && 
                    (this.template.querySelector("[data-id='SurfaceServed__c']").value === ''|| this.template.querySelector("[data-id='SurfaceServed__c']").value === null)) {
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
                            message: 'Popolare il campo Attivazione Anticipata',
                            variant: 'error',
                            mode: 'sticky'
                        });
                    this.dispatchEvent(toastErrorMessage);
                    return;
                }
                if(this.template.querySelector("[data-id='RecessNotice__c']") !== null 
                && (this.template.querySelector("[data-id='RecessNotice__c']").value === ''
                    || this.template.querySelector("[data-id='RecessNotice__c']").value === null)
                && (this.template.querySelector("[data-id='RecessNotice__c']").required === true)) {
                this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Popolare il campo Preavviso Recesso',
                        variant: 'error',
                        mode: 'sticky'
                    });
                this.dispatchEvent(toastErrorMessage);
                return;
                }
                if(this.order.RecordType.DeveloperName=="HDT_RT_TemporaneaNuovaAtt" && this.template.querySelector("[data-id='RequestOption__c']") !== null 
                    && (this.template.querySelector("[data-id='RequestOption__c']").value === ''
                        || this.template.querySelector("[data-id='RequestOption__c']").value === null)) {
                    this.loading = false;
                        const toastErrorMessage = new ShowToastEvent({
                            title: 'Errore',
                            message: 'Popolare il campo Opzione Distribuzione',
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
                            message: 'Popolare il campo Livello pressione',
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
                    || this.template.querySelector("[data-id='PhoneNumber__c']").value === null)
                    && this.template.querySelector("[data-id='PhoneNumber__c']").required === true
                    ) {
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
                if(this.checkFieldAvailable('TemporaryConnectionStartDate__c', true) === ''
                    || this.checkFieldAvailable('TemporaryConnectionEndDate__c', true) === ''
                    || this.checkFieldAvailable('HoursOfUse__c', true) === '')
                {
                    this.showMessage('Errore', 'Popolare i campi obbligatori: Data inizio/fine connessione temporanea e Ore di utilizzo', 'error');
                    return;
                }
                isPreventivo({ord:this.order}).then(result=>{
                    this.loading=false;
                }).catch(error=>{
                    this.showMessage('Errore','Preventivo non calcolato','error');
                    return;
                });
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
                }
            }
            if(currentSectionName === 'fatturazione') {
            this.sectionDataToSubmit['AggregateBilling__c'] = this.template.querySelector("[data-id='AggregateBilling__c']").value;
            }
            if((this.order.RecordType.DeveloperName=="HDT_RT_ConnessioneConAttivazione" || this.order.RecordType.DeveloperName=="HDT_RT_TemporaneaNuovaAtt") && currentSectionName === "dettaglioImpianto"){
                this.getQuoteType(currentSectionIndex, nextSectionStep);
                return;
            }
            this.updateProcess(currentSectionIndex, nextSectionStep);
        }
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
        console.log('# Child Resume From Draft After2>>> ' + this.resumeFromDraftReading);
        let nextIndex = this.availableSteps[currentSectionIndex - 1].name === 'reading' && this.resumeFromDraftReading === false
        ? currentSectionIndex - 2
        : currentSectionIndex - 1
        let previousSectionStep = this.availableSteps[nextIndex].step;

        updateProcessStep({order: {Id: this.order.Id, Step__c: previousSectionStep},isVolture:this.isVolture}).then(data =>{
            this.loading = false;
            this.currentSection = this.availableSteps[nextIndex];
            this.choosenSection = this.availableSteps[nextIndex].name;
            this.activeSections = [this.choosenSection];
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

    isCorrectlyFilled(){
        let wrapAddressObject = [];
        wrapAddressObject = this.template.querySelector(`c-hdt-target-object-address-fields[data-sec="${this.choosenSection}"]`).handleAddressFields();
        let isCorrectlyFilled;
        console.log('# Comune >>> ' + wrapAddressObject['Comune'] );
        console.log('# Via >>> ' + wrapAddressObject['Via']);
        console.log('# Civico >>> ' + wrapAddressObject['Civico']);
        console.log('# Stato >>> ' + wrapAddressObject['Stato']);
        if( wrapAddressObject['Comune'] === undefined || 
            wrapAddressObject['Via'] === undefined || 
            wrapAddressObject['Civico'] === undefined
            || (wrapAddressObject['Flag Verificato'] === undefined || wrapAddressObject['Flag Verificato'] === false)
            ){
                isCorrectlyFilled=false;
        }else{
            isCorrectlyFilled = true;
        }
        return isCorrectlyFilled;
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
        this.wrapAddressObjectSpedizione = this.template.querySelector(`c-hdt-target-object-address-fields[data-sec="${this.choosenSection}"]`).handleAddressFields();
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


    async connectedCallback(){

        checkPermissionSet({}).then(data =>{
            console.log('DATA£££' + data);

            this.permissionFlag = !data;
            console.log('PERMISSIONFLAG££' + this.permissionFlag);
        })

        console.log('Details Callback Start');

        console.log('### VasSubtype__c >>> ' + this.order.VasSubtype__c);

        let initData = await init();
        console.log('initData: ' + JSON.stringify(initData));

        this.loginChannel = initData.loginChannel;

        this.title = 'Processo di ' + this.order.RecordType.Name;
        this.isAccountResidential = this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale';
        this.handleShowModuloInformativo();
        this.handleShowDelibera40();
        this.handleShowInviaModulistica();
        handleSections.apply(this);
       
        // @Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
        if((this.selectedProcess === 'HDT_RT_VAS' && (this.order.OrderReference__c == null || this.order.OrderReference__c === undefined) && (this.order.ContractReference__c == null || this.order.ContractReference__c === undefined)) || this.selectedProcess === 'HDT_RT_Voltura' ||this.selectedProcess === 'HDT_RT_Subentro' || this.selectedProcess === 'HDT_RT_AttivazioneConModifica' || (this.selectedProcess === 'HDT_RT_SwitchIn' && this.order.ProcessType__c != 'Switch in Ripristinatorio') || this.selectedProcess === 'HDT_RT_ConnessioneConAttivazione' || this.selectedProcess === 'HDT_RT_TemporaneaNuovaAtt'){
            this.retryEsitiCreditCheck();
        }        

        this.applyCreditCheckLogic(); 
        this.availableStepsFirst = this.fields.filter(section => section.processVisibility === true);
        console.log("********AVAIBLESTEP:" + JSON.stringify(this.availableStepsFirst));
        this.getFirstStepName();
        this.loadAccordion();

        if( this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' || 
        ( this.order.RecordType.DeveloperName === 'HDT_RT_CambioOfferta' && this.order.ServicePoint__r.CommoditySector__c == 'Acqua' ) ){
            this.isVolture = this.order.RecordType.DeveloperName === 'HDT_RT_Voltura' 
            || (this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch' && this.order.ServicePoint__r.CommoditySector__c.localeCompare('Energia Elettrica') === 0);
            console.log('IsVolture--> '+this.isVolture);
            console.log('ConfirmedSteps--> '+JSON.stringify(this.confirmedSteps));
            console.log('Details Callback End');
            console.log('CommoditySector -> ' + this.order.ServicePoint__r.CommoditySector__c)
            this.readingDisabled = (this.order.ServicePoint__r.CommoditySector__c.localeCompare('Energia Elettrica') === 0);
            console.log('ReadingDisabled? ->' +this.readingDisabled);
        }
        
        console.log('CheckVariables');

        if (this.isCreditCheckVisible) {
            this.dispatchEvent(new CustomEvent('execute_credit_check_poll'));
        }

        if ( this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale'){
            this.isNoDayAfterthought = await isAfterthoughtDaysZero({order: this.order});
        }

        if(this.order.AdditionalAttachments__c != ''){
            this.additionalAttachments = this.order.AdditionalAttachments__c;
        }
        
        console.log('hdtChildOrderProcessDetails - connectedCallback - END');
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
        this.template.querySelector('c-hdt-advance-document-manager').handleShowModal();
        this.template.querySelector('c-hdt-advance-document-manager').initVariables({'tipoDoc': tipoDoc, 'canale': this.loginChannel});
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

    handleCloseAttachment(event){
        console.log('###CloseAttachmentEvent in details>>> ' + JSON.stringify(event.detail));
        event.detail.buttonPressed=true;
        this.closeAttachmentEvent = event.detail;
        if(event.detail.required){
            this.template.querySelector("[data-id='MandatoryAttachments__c']").value = event.detail.required, this.sectionDataToSubmit["MandatoryAttachments__c"]=event.detail.required;
        }
        if(event.detail.additional){
            this.additionalAttachments = event.detail.additional;
            this.template.querySelector("[data-id='AdditionalAttachments__c']").value = event.detail.additional, this.sectionDataToSubmit["AdditionalAttachments__c"]=event.detail.additional;
        }
        
    }

    handleUpdateCodAtecoEvent(event){
        console.log('###Ateco Event >>> ' + JSON.stringify(event.detail));
        if(event.detail?.isRonchi){
            this.template.querySelector("[data-id='AtecoCode__c']").value = safeStr(event.detail?.atecoCode);
            this.template.querySelector("[data-id='RonchiCode__c']").value = safeStr(event.detail?.ronchiCode);
            this.template.querySelector("[data-id='RonchiSubcat__c']").value = safeStr(event.detail?.ronchiSubcategory);
        }
        else{
            this.template.querySelector("[data-id='AtecoCode__c']").value = event.detail;
        }
    }

    handleActiveRepentantStart(event){
        console.log("test call");
        let decorrenza =this.template.querySelector("[data-id='EffectiveDate__c']")?.value;
        let dichiarazione =this.template.querySelector("[data-id='DeclarationDate__c']")?.value;
        this.template.querySelector("c-hdt-active-repentant").startActiveRepentant(decorrenza, dichiarazione);
    }

    handleActiveRepentantFinish(event) {
        console.log('###Missed Due Event >>> ');
        this.template.querySelector("[data-id='OnerousReviewableStartDate__c']").value = event.detail.dateX, this.sectionDataToSubmit["OnerousReviewableStartDate__c"]=event.detail.dateX;
        this.template.querySelector("[data-id='OnerousUnreviewableStartDate__c']").value = event.detail.dateY, this.sectionDataToSubmit["OnerousUnreviewableStartDate__c"]=event.detail.dateY;
        //this.missedDueDate = this.getFormattedDate(event.detail.missedDue);
        const MissingDueAmount = this.template.querySelector("[data-id='MissingDueAmount__c']");
        MissingDueAmount.required = event.detail.missedDue? true : false;
        MissingDueAmount.disabled = event.detail.missedDue? false : true;
        let isPeriodY = event.detail.period=="Y";
        const declineSupport = this.template.querySelector("[data-id='DeclineComputationSupport__c']");
        if(declineSupport)  declineSupport.required = isPeriodY;
        const blockCalcolo = this.template.querySelector("[data-id='BlockOnComputation__c']");
        if(blockCalcolo)    blockCalcolo.value = isPeriodY? "Y" : "", this.sectionDataToSubmit["BlockOnComputation__c"]=isPeriodY? "Y" : "N";
    }
    
}