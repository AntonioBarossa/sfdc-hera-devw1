import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateProcessStep from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.updateProcessStep';
//INIZIO SVILUPPI EVERIS
import updateOrder from '@salesforce/apex/HDT_LC_SelfReading.updateOrder';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import RETROACTIVE_DATE from '@salesforce/schema/Order.RetroactiveDate__c';
//FINE SVILUPPI EVERIS
import updateProcessStepWithExtraFields from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.updateProcessStepWithExtraFields';

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
    @track availableSteps = []; //has steps that are navigated with buttons
    @track availableStepsFirst = []; //has all available steps for current process
    @track confirmedSteps = [];
    @track pendingSteps = [];
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
    fields = {};
    extraFieldsToSubmit = {}; //fields that are updated before step is advanced
    @api mainOrderItem;
    wrapAddressObjectAttivazione = {};
    wrapAddressObjectSpedizione = {};
    @api analisiConsumi;

    get requestOptions(){ return [ //Used to set value for RequestOption__c field
        {"label":"Domestici residenti-D2","value":"Domestici residenti-D2"},
        {"label":"Domestici-TD","value":"Domestici-TD"},
        {"label":"Domestici potenza > 3 Kw-D3","value":"Domestici potenza > 3 Kw-D3"},
        {"label":"AEEG Op BTA3 >3 <=6 kW-E_BTA3","value":"AEEG Op BTA3 >3 <=6 kW-E_BTA3"},
        {"label":"AEEG Op BTA4 >6 <=10 kW-E_BTA4","value":"AEEG Op BTA4 >6 <=10 kW-E_BTA4"}
    ]};

    get previousTraderOptions(){ return [ //Used to set value for PreviousTrader__c field
        {"label":"ENEL ENERGIA SPA-10V0000006","value":"ENEL ENERGIA SPA-10V0000006"},
        {"label":"EDISON PER VOI -10V0000017","value":"EDISON PER VOI -10V0000017"},
        {"label":"ENI GAS & POWER-10V0000012","value":"ENI GAS & POWER-10V0000012"}
    ]};

    //INIZIO SVILUPPI EVERIS

    availableVoltureSection;

    activeVoltureSection = [];

    voltureField = [];

    outputFieldObj = {};
    
    goReading = false;

    @track readingCustomerDate;

    @track disabledReadingDate;

    @track isRetroactive = false;

    @track isReading = false;

    @track lastCallFlag = false;

    handleVoltureToggle(){}

    sysdate(){
        var sysdateIso = new Date().toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return sysdateIso.substr(0, sysdateIso.indexOf('T'));
    }

    handleVoltureChange(event){

        console.log(event.target.value);

        if(event.target.fieldName === 'RetroactiveDate__c' && (event.target.value != null)){

            this.isRetroactive = true;

            console.log(this.isRetroactive);

        } else if(event.target.fieldName === 'RetroactiveDate__c' && (event.target.value == null)){

            this.isRetroactive = false;

            console.log(this.isRetroactive);


        }

        if(!event.target.disabled){
            
            this.outputFieldObj[event.target.fieldName] = event.target.value;

        }

    }

    handelVoltureReading(event){

        this.loading = true;

        let currentVoltureSectionName = 'reading';

        let currentVoltureSectionIndex = this.availableVoltureSection.findIndex(p => p.name == currentVoltureSectionName);

        console.log('Detail Name: ' +event.detail.name);

        if(event.detail.name === 'previous'){

            this.activeVoltureSection = this.availableVoltureSection[currentVoltureSectionIndex -1].name;

            this.loading = false;

            this.dispatchEvent(new CustomEvent('refreshorderchild'));

        } else{

            this.isReading = true;

            updateOrder({fields: JSON.stringify(this.outputFieldObj), recordId: this.order.Id, 
                isRetroactive: this.isRetroactive, isReading: this.isReading,
                readingCustomerDate: event.detail.readingDate, completed:false})
            .then(result =>{

                console.log(result)

                this.activeVoltureSection = this.availableVoltureSection[currentVoltureSectionIndex +1].name;
    
                this.loading = false;

                this.outputFieldObj = {};

                this.refreshValues(this.order.Id);
    
                this.dispatchEvent(new CustomEvent('refreshorderchild'));


            }).catch(error => {

                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                });
                this.dispatchEvent(toastErrorMessage);

            });

        }

    }

    @wire(getRecord, { recordId: '$order.Id', fields: RETROACTIVE_DATE })
    wiredCase({error, data}){
        if(data){

            this.isRetroactive = getFieldValue(data, RETROACTIVE_DATE) != null ? true : false;

            this.outputFieldObj['RetroactiveDate__c'] = getFieldValue(data, RETROACTIVE_DATE);

            console.log('Commodity ' +this.order.ServicePoint__r.CommoditySector__c);

            console.log('Wired Retroactive ' +this.isRetroactive)

            this.disabledReadingDate = !this.isRetroactive;

            if(this.isRetroactive){

                this.readingCustomerDate = this.outputFieldObj['RetroactiveDate__c'];

            } else {

                this.readingCustomerDate = this.sysdate();

            }

            console.log('#DisabledReadingDate --> '+this.disabledReadingDate);

        }else if(error){

            console.log(error);

        }    

    }


    refreshValues(recordId){

        updateRecord({fields: { Id: recordId }});

    }

    //FINE SVILUPPI EVERIS


    handleSectionDataToSubmitCollection(event){
        
        if(event.target.fieldName !== undefined){
            this.sectionDataToSubmit[event.target.fieldName] = event.target.value;
        }

        if(event.target.name !== undefined){
            this.sectionDataToSubmit[event.target.name] = event.target.value;
        }

        console.log(JSON.stringify(this.sectionDataToSubmit));

        let draftData = this.sectionDataToSubmit;
        draftData.Id = this.currentSectionRecordId;

        console.log(JSON.stringify(draftData));

        this.dispatchEvent(new CustomEvent('emitdraftdata', {detail: {
            objectApiName: this.currentSectionObjectApi,
            fields: draftData
        }}));
    }

    handleSectionDiffDataToSubmitCollection(event){
        let currentSection = this.availableSteps.filter(section => section.name === this.choosenSection);

        this.sectionDiffDataToSubmit['Id'] = currentSection[0].diffRecordId;

        if(event.target.fieldName !== undefined){
            this.sectionDiffDataToSubmit[event.target.fieldName] = event.target.value;
        }

        if(event.target.name !== undefined){
            this.sectionDiffDataToSubmit[event.target.name] = event.target.value;
        }

        console.log('********'+JSON.stringify(this.sectionDiffDataToSubmit));

        this.dispatchEvent(new CustomEvent('emitdiffdraftdata', {detail: {
            diffObjectApiName: currentSection[0].diffObjApi,
            diffFields: this.sectionDiffDataToSubmit
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

    applyDateOrdineLogic(){
        let currentSectionIndex = this.availableSteps.findIndex(section => section.name === this.currentSection.name);
        let nextSection = this.availableSteps[currentSectionIndex + 1];
        let nextSectionName = this.availableSteps[currentSectionIndex + 1].name;
        if(this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.ParentOrder__r.ContractSigned__c && nextSectionName === 'dateOrdine'){

            this.extraFieldsToSubmit.Id = this.order.Id;
            this.extraFieldsToSubmit.objectApiName = 'Order';

            if(this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale'){

                if(this.order.WaiverRightAfterthought__c == 'Si'){
                    this.extraFieldsToSubmit.MaxAfterthoughtDate__c = '2021-03-15';
                    nextSection.data.filter(data => data.apiname === 'MaxAfterthoughtDate__c')[0].value = '2021-03-15';

                    this.extraFieldsToSubmit.EffectiveDate__c = '2021-04-01';
                    // nextSection.data.filter(data => data.apiname === 'EffectiveDate__c')[0].value = '2021-04-01';
                } else {
                    this.extraFieldsToSubmit.MaxAfterthoughtDate__c = '2021-03-15';
                    nextSection.data.filter(data => data.apiname === 'MaxAfterthoughtDate__c')[0].value = '2021-03-15';

                    this.extraFieldsToSubmit.EffectiveDate__c = '2021-05-01';
                    // nextSection.data.filter(data => data.apiname === 'EffectiveDate__c')[0].value = '2021-05-01';
                }

            } else {

                this.extraFieldsToSubmit.EffectiveDate__c = '2021-05-01';
                // nextSection.data.filter(data => data.apiname === 'EffectiveDate__c')[0].value = '2021-05-01';
            }
        }
        console.log('applyDateOrdineLogic: ', JSON.stringify(this.extraFieldsToSubmit));
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

    applyCreditCheckLogic(fieldName){
        if(this.order.RecordType.DeveloperName !== undefined ){
            switch (this.order.RecordType.DeveloperName) {
                case 'HDT_RT_Subentro':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    else if (fieldName === 'OutgoingCreditCheckResult__c') {
                        return 'OK';
                    }
                    break;
                case 'HDT_RT_Attivazione':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    break;
                case 'HDT_RT_AttivazioneConModifica':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    break;
                case 'HDT_RT_SwitchIn':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    break;
                case 'HDT_RT_VAS':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    break;
                default:
                    break;
                
            }
            
        }
    }

    getConfirmedSteps(){
        // this.confirmedSteps = this.availableSteps.filter(section => section.step < this.order.Step__c);
        this.confirmedSteps = this.availableStepsFirst.filter(section => (section.name !== 'creditCheck' && section.name !== 'dettaglioImpianto' && section.name !== 'fatturazione' && section.name !== 'datiPrecedenteIntestatario' && section.name !== 'indirizzodiAttivazione' && section.name !== 'indirizzoSpedizione'));

        console.log('this.confirmedSteps: ', JSON.stringify(this.confirmedSteps));
    }

    getPendingSteps(){
        // this.pendingSteps = this.availableSteps.filter(section => section.step >= this.order.Step__c);
        this.pendingSteps = this.availableStepsFirst.filter(section => (section.name === 'creditCheck' || section.name === 'dettaglioImpianto' || section.name === 'fatturazione' || section.name === 'datiPrecedenteIntestatario' || section.name === 'indirizzodiAttivazione' || section.name === 'indirizzoSpedizione'));
        this.availableSteps = this.pendingSteps; //did this because didn't want to replace available steps with pendingSteps as "availableSteps" is used in to many places
        console.log('this.pendingSteps: ', JSON.stringify(this.pendingSteps));
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
        //INIZIO SVILUPPI EVERIS

        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

            console.log('Condizione Verificata');

            this.activeVoltureSection = this.voltureField[this.voltureField.findIndex(p => p.section == 1)].name;

            this.availableVoltureSection = this.voltureField.filter(section => section.active === true);

            this.availableVoltureSection[0].firstStep = true;

            this.availableVoltureSection[this.availableVoltureSection.length - 1].lastStep = true;

            console.log('Sezioni Attive '+this.activeVoltureSection);

            return;

        }


        //FINE SVILUPPI EVERIS

        this.availableStepsFirst = this.fields.filter(section => section.processVisibility === true);
        // this.availableSteps = this.fields.filter(section => section.processVisibility === true);
        this.loadAccordion();
        this.availableSteps[0].firstStep = true;
        this.availableSteps[this.availableSteps.length - 1].lastStep = true;
        this.lastStepNumber = this.availableSteps[this.availableSteps.length - 1].step;

        this.dispatchEvent(new CustomEvent('emitlaststep', {detail: {lastStepNumber: this.lastStepNumber}}));

        console.log('this.lastStepNumber: ',this.lastStepNumber);

        if (this.order.Step__c === 2) {
            this.currentSectionObjectApi = this.availableSteps[0].objectApiName;
            this.currentSectionRecordId = this.availableSteps[0].recordId;
            this.currentSection = this.availableSteps[0];
        } else {
            let currentStep = this.availableSteps.filter(section => section.step === this.order.Step__c);
            console.log('getFirstStepName: ', currentStep);
            this.currentSectionObjectApi = currentStep[0].objectApiName;
            this.currentSectionRecordId = currentStep[0].recordId;
            this.currentSection = currentStep[0];
        }
    }

    /*handleNext(event){ //EVERIS: COMMENTATA FORSE DEPRECATA?

        console.log('event '+event.target.label);

        this.loading = true;

        //INIZIO SVILUPPI EVERIS

        console.log('here 1');

        this.goReading = event.target.name === 'goReading' ? true : false;

        console.log('here 2');

        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

            console.log('here');

            console.log('Nome Sezione: '+event.currentTarget.value);

            let currentVoltureSectionName = event.currentTarget.value;
    
            let currentVoltureSectionIndex = this.availableVoltureSection.findIndex(p => p.name == currentVoltureSectionName);

            let nextVoltureSection = currentVoltureSectionName === 'retroactiveDate' ? 
            (this.availableVoltureSection[currentVoltureSectionIndex + 1].name === 'reading' 
            && event.target.name === 'goReading'
            ? this.availableVoltureSection[currentVoltureSectionIndex + 1].name 
            : this.availableVoltureSection[currentVoltureSectionIndex + 2].name)
            : this.availableVoltureSection[currentVoltureSectionIndex + 1].name;

            if(Object.keys(this.outputFieldObj).length > 0 || currentVoltureSectionName === 'reading'){

                console.log('here');

                console.log(this.outputFieldObj);

                console.log(JSON.stringify(this.outputFieldObj));

                updateOrder({fields: JSON.stringify(this.outputFieldObj), recordId: this.order.Id, 
                    isRetroactive: this.isRetroactive, isReading: this.isReading, completed:false})
                .then(result =>{

                    console.log(result)

                    this.activeVoltureSection = nextVoltureSection;
        
                    this.loading = false;

                    this.showReadingButton = this.availableVoltureSection[currentVoltureSectionIndex + 1].name === 'retroactiveDate'
                    ? true : false;

                    this.outputFieldObj = {};

                    this.refreshValues(this.order.Id);
        
                    this.dispatchEvent(new CustomEvent('refreshorderchild'));


                }).catch(error => {

                    this.loading = false;
                    console.log((error.body.message !== undefined) ? error.body.message : error.message);
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: (error.body.message !== undefined) ? error.body.message : error.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(toastErrorMessage);

                });

            } else {

                this.activeVoltureSection = nextVoltureSection;
        
                this.loading = false;

                this.outputFieldObj = {};
    
                this.dispatchEvent(new CustomEvent('refreshorderchild'));

            }

            return;

        }


        //FINE SVILUPPI EVERIS

        let currentSectionName = event.currentTarget.value;
        let currentSection = this.availableSteps.filter(section => section.name === currentSectionName);
        let currentObjectApiName = currentSection[0].objectApiName;
        let currentRecordId = currentSection[0].recordId;
        let currentSectionIndex = this.availableSteps.findIndex(section => section.name === currentSectionName);
        let nextSectionStep = this.availableSteps[currentSectionIndex + 1].step
        console.log('currentSectionName: ', currentSectionName);
        console.log('currentSection: ', currentSection);
        console.log('currentObjectApiName: ', currentObjectApiName);
        console.log('currentRecordId: ', currentRecordId);
        this.sectionDataToSubmit['Id'] = currentRecordId;
        return this.currentSection.name;
    }*/

    updateProcessStepSimple(currentSectionIndex, nextSectionStep){

        if(Object.keys(this.sectionDiffDataToSubmit).length > 1){
            updateProcessStepWithExtraFields({order: this.order, step: nextSectionStep, extraFields: this.sectionDiffDataToSubmit}).then(data =>{
                this.loading = false;
                this.currentSection = this.availableSteps[currentSectionIndex + 1];
                this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
                this.activeSections = [this.choosenSection];
    
                this.currentSectionObjectApi = this.availableSteps[currentSectionIndex + 1].objectApiName;
                this.currentSectionRecordId = this.availableSteps[currentSectionIndex + 1].recordId;
    
                this.sectionDataToSubmit = {};
                this.extraFieldsToSubmit = {};
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

        } else {
            updateProcessStep({order: this.order, step: nextSectionStep}).then(data =>{
                this.loading = false;
                this.currentSection = this.availableSteps[currentSectionIndex + 1];
                this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
                this.activeSections = [this.choosenSection];
    
                this.currentSectionObjectApi = this.availableSteps[currentSectionIndex + 1].objectApiName;
                this.currentSectionRecordId = this.availableSteps[currentSectionIndex + 1].recordId;
    
                this.sectionDataToSubmit = {};
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
    }

    updateProcessWithDataToSubmit(currentSectionIndex, nextSectionStep){
        updateProcessStep({order: this.order, step: nextSectionStep, objectApiName: this.currentSection.objectApiName, objectToUpdate: this.sectionDataToSubmit}).then(data =>{
            this.loading = false;
            this.currentSection = this.availableSteps[currentSectionIndex + 1];
            this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
            this.activeSections = [this.choosenSection];

            this.currentSectionObjectApi = this.availableSteps[currentSectionIndex + 1].objectApiName;
            this.currentSectionRecordId = this.availableSteps[currentSectionIndex + 1].recordId;
            this.sectionDataToSubmit = {};            
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

    updateProcessWithExtraFieldsSimple(currentSectionIndex, nextSectionStep){

        let paramsObject = {};

        if(Object.keys(this.sectionDiffDataToSubmit).length > 1){
            paramsObject = {order: this.order, step: nextSectionStep, extraFields: this.extraFieldsToSubmit, diffObjectToUpdate: this.sectionDiffDataToSubmit};
        } else {
            paramsObject = {order: this.order, step: nextSectionStep, extraFields: this.extraFieldsToSubmit};
        }

        updateProcessStepWithExtraFields(paramsObject).then(data =>{
            this.loading = false;
            this.currentSection = this.availableSteps[currentSectionIndex + 1];
            this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
            this.activeSections = [this.choosenSection];

            this.currentSectionObjectApi = this.availableSteps[currentSectionIndex + 1].objectApiName;
            this.currentSectionRecordId = this.availableSteps[currentSectionIndex + 1].recordId;

            this.sectionDataToSubmit = {};
            this.extraFieldsToSubmit = {};
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

    updateProcessWithDataToSubmitAndExtraFields(currentSectionIndex, nextSectionStep){

        let paramsObject = {};

        if(Object.keys(this.sectionDiffDataToSubmit).length > 1){
            paramsObject = {order: this.order, step: nextSectionStep, extraFields: this.extraFieldsToSubmit, objectApiName: this.currentSection.objectApiName, objectToUpdate: this.sectionDataToSubmit, diffObjectToUpdate: this.sectionDiffDataToSubmit};
        } else {
            paramsObject = {order: this.order, step: nextSectionStep, extraFields: this.extraFieldsToSubmit, objectApiName: this.currentSection.objectApiName, objectToUpdate: this.sectionDataToSubmit};
        }

        updateProcessStepWithExtraFields(paramsObject).then(data =>{
            this.loading = false;
            this.currentSection = this.availableSteps[currentSectionIndex + 1];
            this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
            this.activeSections = [this.choosenSection];

            this.currentSectionObjectApi = this.availableSteps[currentSectionIndex + 1].objectApiName;
            this.currentSectionRecordId = this.availableSteps[currentSectionIndex + 1].recordId;
            this.sectionDataToSubmit = {};
            this.extraFieldsToSubmit = {};
            
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

    handleNext(event){

        this.loading = true;

        //INIZIO SVILUPPI EVERIS

        console.log('here 1');

        this.goReading = event.target.name === 'goReading' ? true : false;

        console.log('here 2');

        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

                console.log('here');

                console.log('Nome Sezione: '+event.currentTarget.value);

                let currentVoltureSectionName = event.currentTarget.value;
        
                let currentVoltureSectionIndex = this.availableVoltureSection.findIndex(p => p.name == currentVoltureSectionName);

                let nextVoltureSection = currentVoltureSectionName === 'retroactiveDate' ? 
                (this.availableVoltureSection[currentVoltureSectionIndex + 1].name === 'reading' 
                && event.target.name === 'goReading'
                ? this.availableVoltureSection[currentVoltureSectionIndex + 1].name 
                : this.availableVoltureSection[currentVoltureSectionIndex + 2].name)
                : this.availableVoltureSection[currentVoltureSectionIndex + 1].name;

                if(Object.keys(this.outputFieldObj).length > 0 || currentVoltureSectionName === 'reading'){

                    console.log('here');

                    console.log(this.outputFieldObj);

                    console.log(JSON.stringify(this.outputFieldObj));

                    updateOrder({fields: JSON.stringify(this.outputFieldObj), recordId: this.order.Id, 
                        isRetroactive: this.isRetroactive, isReading: this.isReading, completed:false})
                    .then(result =>{

                        console.log(result);

                        if(nextVoltureSection === 'reading' && !this.lastCallFlag){

                            this.lastCallFlag = true;

                            this.template.querySelector('c-hdt-self-reading').handleClick();

                        }

                        this.activeVoltureSection = nextVoltureSection;
            
                        this.loading = false;

                        this.showReadingButton = this.availableVoltureSection[currentVoltureSectionIndex + 1].name === 'retroactiveDate'
                        ? true : false;

                        this.outputFieldObj = {};

                        this.refreshValues(this.order.Id);
            
                        this.dispatchEvent(new CustomEvent('refreshorderchild'));

                    }).catch(error => {

                        this.loading = false;
                        console.log((error.body.message !== undefined) ? error.body.message : error.message);
                        const toastErrorMessage = new ShowToastEvent({
                            title: 'Errore',
                            message: (error.body.message !== undefined) ? error.body.message : error.message,
                            variant: 'error',
                        });
                        this.dispatchEvent(toastErrorMessage);

                    });

                } else {

                    this.activeVoltureSection = nextVoltureSection;
            
                    this.loading = false;

                    this.outputFieldObj = {};
        
                    this.dispatchEvent(new CustomEvent('refreshorderchild'));

                }

                if(this.availableVoltureSection[currentVoltureSectionIndex + 1].lastStep){

                    this.dispatchEvent(new CustomEvent('emitlaststep', {detail: {lastStepNumber: 1}}));

                }

                return;

            }


            //FINE SVILUPPI EVERIS

        let currentSectionName = event.currentTarget.value;
        let currentSection = this.availableSteps.filter(section => section.name === currentSectionName);
        let currentObjectApiName = currentSection[0].objectApiName;
        let currentRecordId = currentSection[0].recordId;
        let currentSectionIndex = this.availableSteps.findIndex(section => section.name === currentSectionName);
        let nextSectionStep = this.availableSteps[currentSectionIndex + 1].step;
        console.log('currentSectionName: ', currentSectionName);
        console.log('currentSection: ', currentSection);
        console.log('currentObjectApiName: ', currentObjectApiName);
        console.log('currentRecordId: ', currentRecordId);

        if(currentSectionName === 'creditCheck'){
            this.sectionDataToSubmit['IncomingCreditCheck__c'] = this.applyCreditCheckLogic('IncomingCreditCheck__c');
            this.sectionDataToSubmit['OutgoingCreditCheckResult__c'] = this.applyCreditCheckLogic('OutgoingCreditCheckResult__c');
            this.sectionDataToSubmit['CreditCheckDescription__c'] = this.template.querySelector("[data-id='CreditCheckDescription__c']").value;

        }

        if(currentSectionName === 'indirizzodiAttivazione'){
            this.handleWrapAddressObjectAttivazione();
        }

        if(currentSectionName === 'indirizzoSpedizione'){
            this.handleWrapAddressObjectSpedizione();
        }

        this.applyDateOrdineLogic();
        
        this.sectionDataToSubmit['Id'] = currentRecordId;

        console.log('handleNext: ', JSON.parse(JSON.stringify(this.sectionDataToSubmit)));

        if(currentSectionName === 'dettaglioImpianto'){
            if(this.template.querySelector("[data-id='CommoditySector__c']").value === 'Energia Elettrica' && (this.template.querySelector("[data-id='UseTypeEnergy__c']").value === null || this.template.querySelector("[data-id='UseTypeEnergy__c']").value === '')){
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

            if(this.template.querySelector("[data-id='Disconnectable__c']").value === 'NO'){
                
                let errorMessage = '';

                console.log(this.template.querySelector("[data-id='DisconnectibilityType__c']").value);
                if(this.template.querySelector("[data-id='DisconnectibilityType__c']").value === null){
                    errorMessage = 'Popolare Telefono Non Disalimentabilita';
                } 
                
                console.log(this.template.querySelector("[data-id='DisconnectibilityPhone__c']").value);
                if(this.template.querySelector("[data-id='DisconnectibilityPhone__c']").value === null){
                    errorMessage = 'Popolare Tipologia Disalimentabilita';
                }
                
                console.log('errorMessage: ', errorMessage);

                if(errorMessage !== ''){
                    this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: errorMessage,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    return;
                }
                
            }
        }

        if (Object.keys(this.sectionDataToSubmit).length > 1) {

            if(Object.keys(this.extraFieldsToSubmit).length > 1){
                this.updateProcessWithDataToSubmitAndExtraFields(currentSectionIndex, nextSectionStep);
            } else {
                this.updateProcessWithDataToSubmit(currentSectionIndex, nextSectionStep);
            }

        } else {
            
            if(Object.keys(this.extraFieldsToSubmit).length > 1){
                this.updateProcessWithExtraFieldsSimple(currentSectionIndex, nextSectionStep);
            } else {
                this.updateProcessStepSimple(currentSectionIndex, nextSectionStep);
            }
        }

    }

    handleSectionToggle(event) {
        this.activeSections = [this.choosenSection];
    }

    handlePrevious(event){
        this.loading = true;
        console.log('handle Click Event Data: ', event.currentTarget.value);

        let currentSectionName = event.currentTarget.value;

        //INIZIO SVILUPPI EVERIS
        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

            let currentVoltureSectionIndex = this.availableVoltureSection.findIndex(p => p.name === currentSectionName);

            let previousVoltureSection = currentSectionName === 'processVariable' ?
            (this.availableVoltureSection[currentVoltureSectionIndex - 1].name === 'reading' && this.goReading
            ? this.availableVoltureSection[currentVoltureSectionIndex - 1].name 
            : this.availableVoltureSection[currentVoltureSectionIndex - 2].name)
            : this.availableVoltureSection[currentVoltureSectionIndex - 1].name;

            console.log('Previous Section '+previousVoltureSection);

            this.activeVoltureSection = previousVoltureSection;
            
            console.log(this.activeVoltureSection);

            this.loading = false;
        
            this.dispatchEvent(new CustomEvent('refreshorderchild'));

        }
        //FINE SVILUPPI EVERIS

        let currentSectionIndex = this.availableSteps.findIndex(section => section.name === currentSectionName);

        let previousSectionStep = this.availableSteps[currentSectionIndex - 1].step;

        updateProcessStep({order: this.order, step: previousSectionStep}).then(data =>{
            this.loading = false;
            this.currentSection = this.availableSteps[currentSectionIndex - 1];

            this.currentSectionObjectApi = this.availableSteps[currentSectionIndex - 1].objectApiName;
            this.currentSectionRecordId = this.availableSteps[currentSectionIndex - 1].recordId;
            this.sectionDataToSubmit = {};
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

    //INIZIO SVILUPPI EVERIS        
        this.voltureField =[
            {

                section: 1,
                label: 'Credit Check',
                name: 'creditCheck',
                reading: false,
                readingButton: false,
                inputField: false,
                active: true,
                data:
                [
                    {
                        label: 'Esito Credit Check Uscente',
                        apiname: 'OutgoingCreditCheck',
                        value: 'OK',
                        type: 'text',
                        disabled: true,
                        required:false
                    },
                    {
                        label: 'Esito Credit Check Entrante',
                        apiname: 'OutgoingCreditCheck',
                        value: 'OK',
                        type: 'text',
                        disabled: true,
                        required:false
                    },
                    {
                        label: 'Descrizione Esito',
                        apiname: 'CreditCheckDescription',
                        value: 'OK',
                        type: 'text',
                        disabled: true,
                        required:false
                    }
                ]


            },
            {

                section: 2,
                label: 'Data Retroattiva',
                name: 'retroactiveDate',
                reading: false,
                readingButton: true,
                inputField: true,
                recordId:this.order.Id,
                objectApiName:'Order',
                active: true,
                data:
                [
                    {
                        label: 'Data Retroattiva',
                        apiname: 'RetroactiveDate__c',
                        type: 'Date',
                        value: null,
                        disabled: false
                    }
                ]

            },
            {

                section: 3,
                label: 'Autolettura',
                name: 'reading',
                reading: true,
                readingButton: false,
                inputField: false,
                active: true

            },
            {
                section: 4,
                label: 'Variabili di Processo',
                name: 'processVariable',
                reading:false,
                readingButton: false,
                inputField:true,
                recordId:this.order.Id,
                objectApiName:'Order',
                active:true,
                data:
                [
                    {
                        apiname: 'VoltureType__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'SignedDate__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: '',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: '',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'Volture__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'AccountId',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'PhoneNumber__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'Email__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'WithdrawalClass__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'AnnualConsumption__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'Market__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'SupplyType__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'Implant__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'ClientCategory__c',
                        required: false,
                        disabled: true
                    }
                ]
            },
            {
                section: 5,
                label: 'Cliente Uscente',
                name: 'exitingCustomer',
                reading:false,
                readingButton: false,
                inputField:true,
                recordId:this.order.ServicePoint__r.Account__c,
                objectApiName:'Account',
                active:true,
                data:
                [
                    {
                        apiname: 'Name',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'FiscalCode__c',
                        required: false,
                        disabled: true
                    },
                    {
                        apiname: 'VATNumber__c',
                        required: false,
                        disabled: true
                    }
                ]
            }
    ];


    //FINE SVILUPPI EVERIS
    
        this.fields = [
            {
                step: 3,
                label: 'Cliente Uscente',
                name: 'clienteUscente',
                objectApiName: 'Account',
                recordId: this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__r.Account__c : '',
                processVisibility: this.order.ServicePoint__c !== undefined && this.order.ServicePoint__r.Account__c !== this.order.AccountId && this.order.RecordType.DeveloperName === 'HDT_RT_Subentro',
                data: [
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
                step: 4,
                label: 'Credit check',
                name: 'creditCheck',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VAS',
                data: [
                    {
                        'label': 'Esito credit Check Entrante',
                        'apiname': 'IncomingCreditCheck__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.applyCreditCheckLogic('IncomingCreditCheck__c'),
                        'processVisibility': ''
                    },
                    {
                        'label': 'Esito credit Check Uscente',
                        'apiname': 'OutgoingCreditCheckResult__c',
                        'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName !== 'HDT_RT_SwitchIn' && this.order.RecordType.DeveloperName !== 'HDT_RT_VAS',
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
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 5,
                label: 'Dati precedente intestatario',
                name: 'datiPrecedenteIntestatario',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Nome precedente intestatario',
                        'apiname': 'PreviousHolderFirstName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome precedente intestatario',
                        'apiname': 'PreviousHolderLastName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'C.F. Precdente intestatario',
                        'apiname': 'PreviousHolderFiscalCode__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Ragione sociale precedente intestatario',
                        'apiname': 'PreviousHoldeCompanyName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'P.Iva precedente intestatario',
                        'apiname': 'PreviousHolderVatNumber__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 6,
                label: 'Dettaglio impianto',
                name: 'dettaglioImpianto',
                objectApiName: 'ServicePoint__c',
                diffObjApi: 'Order',
                diffRecordId: this.order.Id,
                hasCalculateButton: this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica',
                recordId: this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__c : '',
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
               data: [
                {
                    'label': 'POD/PdR',
                    'apiname': 'ServicePointCode__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo Impianto',
                    'apiname': 'ImplantType__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
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
                    'label': 'Setore merceologico',
                    'apiname': 'CommoditySector__c',
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
                    'label': 'Distributore',
                    'apiname': 'Distributor__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza disponibile',
                    'apiname': 'PowerAvailable__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza impegnata',
                    'apiname': 'PowerContractual__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
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
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Categoria disalimentabilità', //2
                    'apiname': 'DisconnectibilityType__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Recapito telefonico',
                    'apiname': 'DisconnectibilityPhone__c', //3
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false,
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
                    'disabled': false,
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
                    'required': true,
                    'disabled': true,
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
                    'label': 'Misuratore',
                    'apiname': 'MeterSN__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Residente all\'indirizzo di Fornitura',
                    'apiname': 'Resident__c',
                    'typeVisibility': this.typeVisibility('ele'),
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
                {
                    'label': 'ConnectionMandate__c',
                    'apiname': 'ConnectionMandate__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'SelfCertificationConnection__c',
                    'apiname': 'SelfCertificationConnection__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'ConnectionType__c',
                    'apiname': 'ConnectionType__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'Data richiesta recesso altro trader',
                    'apiname': 'TraderRecessDate__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'Voltura c/o VT',
                    'apiname': 'VolturaThirdTrader__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'Esecuzione Anticipata',
                    'apiname': 'RecessNotice__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'Rinuncia Diritto di Ripensamento',
                    'apiname': 'WaiverRightAfterthought__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': '',
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'Opzione richiesta',
                    'apiname': 'RequestOption__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                    'required': false,
                    'disabled': false,
                    'value': this.order.RequestOption__c,
                    'processVisibility': '',
                    'isMockPicklist': true,
                    'mockOptions': this.requestOptions,
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'Società uscente',
                    'apiname': 'PreviousTrader__c',
                    'typeVisibility': this.typeVisibility('both') && this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                    'required': false,
                    'disabled': false,
                    'value': this.order.PreviousTrader__c,
                    'processVisibility': '',
                    'isMockPicklist': true,
                    'mockOptions': this.previousTraderOptions,
                    'diffObjApi': 'Order',
                    'diffRecordId': this.order.Id
                },
                {
                    'label': 'RequestPower__c',
                    'apiname': 'RequestPower__c',
                    'typeVisibility': this.typeVisibility('ele') && this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica',
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'RequestVoltage__c',
                    'apiname': 'RequestVoltage__c',
                    'typeVisibility': this.typeVisibility('ele') && this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica',
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                }
               ]
            },
            {
                step: 7,
                label: 'Indirizzo fornitura',
                name: 'indirizzoFornitura',
                objectApiName: 'ServicePoint__c',
                recordId: this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__c : '',
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'SupplyCity__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Via',
                        'apiname': 'SupplyStreet__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'SupplyStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'SupplyPlace__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'SupplyProvince__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'SupplyPostalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'SupplyCountry__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'undefined3',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 8,
                label: this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale',
                name: 'indirizzoResidenzaOsedeLegale',
                objectApiName: 'Account',
                recordId: this.order.AccountId,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
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
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 10,
                label: 'Fatturazione elettronica',
                name: 'fatturazioneElettronicaClienteNonResidenziale',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn')
                && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                data:[
                    {
                        'label': 'Codice Destinatario',
                        'apiname': 'SubjectCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'PEC Fatturazione Elettronica',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Modalità invio Fatturazione',
                        'apiname': 'ElectronicInvoicingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipo invio fattura XML',
                        'apiname': 'XMLType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIG',
                        'apiname': 'CIG__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CUP',
                        'apiname': 'CUP__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 12,
                label: 'Riepilogo Dati',
                name: 'riepilogoDatiAmend',
                objectApiName: '',
                recordId: '',
                manualDisplay: true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus',
                data: [
                    {
                        'label': 'Numero Contratto',
                        'apiname': 'CotractReference__c',
                        'typeVisibility': this.order.ContractReference__c !== undefined,
                        'required': false,
                        'disabled': true,
                        'value': this.order.ContractReference__c !== undefined ? this.order.ContractReference__r.ContractNumber : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Uso energia ele',
                        'apiname': 'Service Point.UseTypeEnergy__c',
                        'typeVisibility': this.typeVisibility('ele'),
                        'required': false,
                        'disabled': true,
                        'value': this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__r.UseTypeEnergy__c : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Categoria d\'uso',
                        'apiname': 'Service Point.UseTypeEnergy__c',
                        'typeVisibility': this.typeVisibility('gas'),
                        'required': false,
                        'disabled': true,
                        'value': this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__r.UseCategory__c : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'POD/PDR',
                        'apiname': 'Service Point.ServicePointCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.order.ServicePoint__c !== undefined ? this.order.ServicePoint__r.ServicePointCode__c : '',
                        'processVisibility': ''
                    },
                ]
            },
            {
                step: 13,
                label: 'Analisi Consumi',
                name: 'analisiConsumi',
                objectApiName: 'OrderItem',
                recordId: this.analisiConsumi.Id !== undefined ? this.analisiConsumi.Id : '',//this.analisiConsumi.Id
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_ScontiBonus' && this.analisiConsumi.Id !== undefined,
                data: [
                    {
                        'label': 'Proprietario',
                        'apiname': 'OwnerAC__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipo Casa',
                        'apiname': 'DwellingType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'N. Abitanti',
                        'apiname': 'OccupantsNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Mq. Casa',
                        'apiname': 'Surface__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 14,
                label: 'Riepilogo Dati',
                name: 'riepilogoDatiVas',
                // objectApiName: 'Order',
                // recordId: this.order.Id,
                // diffObjApi: 'Account',
                // diffRecordId: this.order.AccountId,
                // diffObjApi2: 'Product2',
                // diffRecordId2: this.mainOrderItem.Product2Id,
                manualDisplay: true,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS',
                data: [
                    {
                        'label': 'Contratto di riferimento',
                        'apiname': 'CotractReference__c',
                        'typeVisibility': this.order.ContractReference__c !== undefined,
                        'required': false,
                        'disabled': true,
                        'value': this.order.ContractReference__c !== undefined ? this.order.ContractReference__r.ContractNumber : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Ordine di riferimento',
                        'apiname': 'OrderReference__c',
                        'typeVisibility': this.order.OrderReference__c !== undefined,
                        'required': false,
                        'disabled': true,
                        'value':this.order.OrderReference__c !== undefined ? this.order.OrderReference__r.OrderNumber : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Società di vendita',
                        'apiname': 'SalesCompany__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': true,
                        'value': this.order.SalesCompany__c !== undefined ? this.order.SalesCompany__c : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Campagna',
                        'apiname': 'Campaign__c',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': true,
                        'value': this.order.Campaign__c !== undefined ? this.order.Campaign__r.Name : '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipo VAS',
                        'apiname': 'Family',
                        'diffObjApi2': 'Product2',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': true,
                        'value': this.mainOrderItem.Product2.Family,
                        'processVisibility': ''
                    },
                    {
                        'label': 'Sottotipo VAS',
                        'apiname': 'Name',
                        'diffObjApi2': 'Product2',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': true,
                        'value': this.mainOrderItem.Product2.Name,
                        'processVisibility': ''
                    },
                    {
                        'label': 'Categoria Cliente',
                        'apiname': 'Category__c',
                        'diffObjApi': 'Account',
                        'typeVisibility': true,
                        'required': false,
                        'disabled': true,
                        'value': this.order.Account.Category__c !== undefined ? this.order.Account.Category__c : '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 15,
                label: 'Indirizzo di attivazione',
                name: 'indirizzodiAttivazione',
                hasAddrComp: true,
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS',
                data: [
                    
                ]
            },
            {
                step: 16,
                label: 'Indirizzo spedizione',
                name: 'indirizzoSpedizione',
                hasAddrComp: true,
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS',
                data: [
                    
                ]
            },
            {
                step: 9,
                label:'Fatturazione',
                name: 'fatturazione',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                diffObjApi: 'Order',
                diffRecordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Modalità Invio Bolletta',
                        'apiname': 'BillSendingMethod__c',
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
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Email PEC invio Bolletta',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
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
                        'apiname': 'InvoicingCity__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Stato ',
                        'apiname': 'InvoicingCountry__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'InvoicingProvince__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nome Via',
                        'apiname': 'InvoicingStreetName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'InvoicingStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CAP',
                        'apiname': 'InvoicingPostalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice ISTAT',
                        'apiname': 'InvoicingCityCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'AggregateBilling__c',
                        'apiname': 'AggregateBilling__c',
                        'diffObjApi': 'Order',
                        'diffRecordId': this.order.Id,
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': false,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 17,
                label: 'Metodo pagamento',
                name: 'metodoPagamento',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' || this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Modalità di Pagamento',
                        'apiname': 'PaymentMethod__c',
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
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Numeri di Controllo',
                        'apiname': 'IbanCIN_IBAN__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIN',
                        'apiname': 'IbanCIN__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'ABI',
                        'apiname': 'IbanABI__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CAB',
                        'apiname': 'IbanCAB__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Numero conto corrente',
                        'apiname': 'IbanCodeNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipologia Intestatario',
                        'apiname': 'SignatoryType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'OtherPayer__c',
                        'apiname': 'OtherPayer__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Fiscale intestatario c/c',
                        'apiname': 'BankAccountSignatoryFiscalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nome Intestatario c/c',
                        'apiname': 'BankAccountSignatoryFirstName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome Intestario c/c',
                        'apiname': 'BankAccountSignatoryLastName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Contact di riferimento',
                        'apiname': 'undefined8',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 18,
                label: 'Date ordine',
                name: 'dateOrdine',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.ParentOrder__r.ContractSigned__c,
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
                    }
                    // {
                    //     'label': 'Data decorrenza',
                    //     'apiname': 'EffectiveDate__c',
                    //     'typeVisibility': this.typeVisibility('both'),
                    //     'required': false,
                    //     'disabled': true,
                    //     'value': '',
                    //     'processVisibility': ''
                    // }
                ]
            },
            {
                lastStep: true,
                step: 19,
                label: 'Metodo firma canale invio',
                name: 'metodoFirmaCanaleInvio',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_VAS' || (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'),
                data: [
                    {
                        'label': 'Metodo firma',
                        'apiname': 'SignatureMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Invio doc',
                        'apiname': 'DocSendingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            }
        ];
    }

    handleWrapAddressObjectAttivazione(){

        this.wrapAddressObjectAttivazione = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();

        console.log('handleWrapAddressObject: ', JSON.stringify(this.wrapAddressObjectAttivazione));

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

        console.log('handleWrapAddressObject: ', JSON.stringify(this.wrapAddressObjectSpedizione));

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
        console.log('isAccountResidential: ', this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale');
        console.log('hdtChildOrderProcessDetails: ', JSON.parse(JSON.stringify(this.order)));
        console.log('mainOrderItem: ', JSON.parse(JSON.stringify(this.mainOrderItem)));
        console.log('analisiConsumi: ', JSON.parse(JSON.stringify(this.analisiConsumi)));
        
        
        this.title = 'Processo di ' + this.order.RecordType.Name;
        this.isAccountResidential = this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale';
        this.handleShowModuloInformativo();
        this.handleShowDelibera40();
        this.handleShowInviaModulistica();
        this.handleFields();
        this.applyCreditCheckLogic();

        this.availableStepsFirst = this.fields.filter(section => section.processVisibility === true);
        this.loadAccordion();

        if(this.pendingSteps.length > 0){
            this.choosenSection = this.getFirstStepName();
            this.activeSections = [this.getFirstStepName()];
        }
    }

    renderedCallback(){
        if(this.currentSection.name === 'indirizzodiAttivazione'){
            this.handleWrapAddressObjectAttivazioniReverse();
        }

        if(this.currentSection.name === 'indirizzoSpedizione'){
            this.handleWrapAddressObjectSpedizioneReverse();
        }
    }
}