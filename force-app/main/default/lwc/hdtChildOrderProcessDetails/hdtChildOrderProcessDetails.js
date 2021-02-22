import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateProcessStep from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.updateProcessStep';
//INIZIO SVILUPPI EVERIS
import updateOrder from '@salesforce/apex/HDT_LC_SelfReading.updateOrder';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import RETROACTIVE_DATE from '@salesforce/schema/Order.RetroactiveDate__c';
//FINE SVILUPPI EVERIS

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
    availableSteps = [];
    loading = false;
    showModuloInformativo = false;
    showDelibera40 = false;
    showInviaModulistica = false;
    @track sectionDataToSubmit = {};

    //INIZIO SVILUPPI EVERIS

    availableVoltureSection;

    activeVoltureSection = [];

    voltureField = [];

    outputFieldObj = {};
    
    goReading = false;

    @track isRetroactive = false;

    @track isReading = false;

    handleVoltureToggle(){}

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

            console.log('Wired Retroactive ' +this.isRetroactive)

        }else if(error){

            console.log(error);

        }    

    }


    refreshValues(recordId){

        updateRecord({fields: { Id: recordId }});

    }

    //FINE SVILUPPI EVERIS


    handleSectionDataToSubmitCollection(event){
        console.log('handleSectionDataToSubmitCollection fieldName: ', event.target.fieldName);
        console.log('handleSectionDataToSubmitCollection value: ', event.target.value);
        this.sectionDataToSubmit[event.target.fieldName] = event.target.value;
        console.log('this.sectionDataToSubmit: ', JSON.parse(JSON.stringify(this.sectionDataToSubmit)));
    }

    handleShowModuloInformativo(){
        if ((this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
            || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
            || this.order.RecordType.DeveloperName === 'HDT_RT_RiattivazioniNonMorose')
            && this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas') {
            this.showModuloInformativo = true;
        }
    };

    handleShowDelibera40(){
        if ((this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
            || this.order.RecordType.DeveloperName === 'HDT_RT_RiattivazioniNonMorose')
            && this.order.Deliberation__c === 'In Delibera'
            && this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas') {
            this.showDelibera40 = true;
        }
    }

    handleShowInviaModulistica(){

        if(this.order.ServicePoint__r.MeterClass__c !== undefined){
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

        if(this.order !== undefined ){
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

    fields = {};

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
                default:
                    break;
                
            }
            
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



        this.availableSteps = this.fields.filter(section => section.processVisibility === true);
        this.availableSteps[0].firstStep = true;
        this.availableSteps[this.availableSteps.length - 1].lastStep = true;

        if (this.order.Step__c === 2) {
            return this.availableSteps[0].name;
        } else {
            let currentStep = this.availableSteps.filter(section => section.step === this.order.Step__c);
            console.log('getFirstStepName: ', currentStep);
            return currentStep[0].name;
        }
    }

    handleNext(event){
        this.loading = true;

        this.goReading = event.target.name === 'goReading' ? true : false;

        //INIZIO SVILUPPI EVERIS
        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

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

        console.log('handleNext: ', JSON.parse(JSON.stringify(this.sectionDataToSubmit)));

        if (Object.keys(this.sectionDataToSubmit).length > 1) {
            updateProcessStep({order: this.order, step: nextSectionStep, objectApiName: currentObjectApiName, objectToUpdate: this.sectionDataToSubmit}).then(data =>{
                this.loading = false;
                this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
                this.activeSections = [this.choosenSection];
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
        } else {
            updateProcessStep({order: this.order, step: nextSectionStep}).then(data =>{
                this.loading = false;
                this.choosenSection = this.availableSteps[currentSectionIndex + 1].name;
                this.activeSections = [this.choosenSection];
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

        let previousSectionStep = this.availableSteps[currentSectionIndex - 1].step

        updateProcessStep({order: this.order, step: previousSectionStep}).then(data =>{
            this.loading = false;
            this.choosenSection = this.availableSteps[currentSectionIndex - 1].name;
            this.activeSections = [this.choosenSection];
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
                        apiname: 'AnnualConsumption__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'SignedDate__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'DeliveryAddress__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'WithdrawalClass__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'PaymentMode__c',
                        required: true,
                        disabled: false
                    },
                    {
                        apiname: 'BillSendMode__c',
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
                recordId: this.order.ServicePoint__r.Account__c,
                processVisibility: 
                    (this.order.ServicePoint__r.Account__c !== this.order.AccountId) 
                    && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'),
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
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
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
                        'typeVisibility': this.typeVisibility('both'),
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
                label: 'Dettaglio impianto',
                name: 'dettaglioImpianto',
                objectApiName: 'ServicePoint__c',
                diffObjApi: 'Order',
                diffRecordId: this.order.Id,
                recordId: this.order.ServicePoint__c,
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
                    'typeVisibility': this.typeVisibility('ele'),
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
                    'label': 'Potenzialità massima richiesta',
                    'apiname': 'MaxRequiredPotential__c',
                    'typeVisibility': this.typeVisibility('gas'),
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
                    'typeVisibility': this.typeVisibility('both'),
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
               ]
            },
            {
                step: 6,
                label: 'Indirizzo fornitura',
                name: 'indirizzoFornitura',
                objectApiName: 'ServicePoint__c',
                recordId: this.order.ServicePoint__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
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
                step: 7,
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
                step: 8,
                label:'Fatturazione',
                name: 'fatturazione',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
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
                    }
                ]
            },
            {
                step: 9,
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
                step: 10,
                label: 'Metodo pagamento',
                name: 'metodoPagamento',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
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
                lastStep: true,
                step: 11,
                label: 'Metodo firma canale invio',
                name: 'metodoFirmaCanaleInvio',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
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

    connectedCallback(){
        console.log('isAccountResidential: ', this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale');
        console.log('hdtChildOrderProcessDetails: ', JSON.parse(JSON.stringify(this.order)));
        this.title = 'Processo di ' + this.order.RecordType.Name;
        this.isAccountResidential = this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale';
        this.handleShowModuloInformativo();
        this.handleShowDelibera40();
        this.handleShowInviaModulistica();
        this.handleFields();
        this.applyCreditCheckLogic();
        this.choosenSection = this.getFirstStepName();
        this.activeSections = [this.getFirstStepName()];
    }
}