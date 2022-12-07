import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import init from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.init';
import next from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.next';
import checkVasAndCommodity from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.checkVasAndCommodity';
import getConsumptionAnnualForVas from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.getConsumptionAnnualForVas';
import checkContendibilita from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.checkContendibilita';
import checkCompatibility from '@salesforce/apex/HDT_UTL_MatrixCompatibility.checkCompatibilitySales';
import retrieveOrderCreditCheck from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.retrieveOrderCreditCheck';


// @Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
import callServiceCreditCheck from '@salesforce/apex/HDT_WS_CreditCheck.callService';
export default class hdtChildOrderProcessPrecheck extends LightningElement {
    @api order;
    precheck = false;
    causale = '';
    causaleCompatibilita = '';
    selectedProcess = ''; //old processSelector (deprecated)
    selectedProcessObject = ''; //new processSelector
    compatibilita = false;
    loaded = true;
    @track deliberation = '';
    showDeliberation = false;
    @track disabledDeliberation = false;
    showEsitoCheck = false;
    vasAmendDisabledInput = false;
    disabledSelectProcess = false;
    options;
    @track processesReference = [];
    value;
    serviceRequest;
    creditCheckFields = [];
    creditCheckResult = {};
    service = '';
    pickValue = '';
    causaleContendibilita = '';
    consumptionAnnualForVas;

    get isNotBillable(){
        return this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && !this.order.IsBillableVas__c;
    }
    get isBillable(){
        return this.order.RecordType.DeveloperName === 'HDT_RT_VAS' && this.order.IsBillableVas__c;
    }

    get isCreditCheckVisible(){
        return this.order.Step__c >= 2 && 
        (
            this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_ConnessioneConAttivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_TemporaneaNuovaAtt'
                || (this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn' && this.order.ProcessType__c !== 'Switch in Ripristinatorio')
                || (this.isNotBillable && this.order.SBQQ__Quote__c != this.order?.OrderReference__r?.SBQQ__Quote__c)
                || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'
                || this.order.RecordType.DeveloperName === 'HDT_RT_VolturaConSwitch'
        );
    }

    get disabledNext(){
        let result = true;
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || (this.selectedProcessObject === '') || this.compatibilita === false){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledSave: ', result);
        return result;
    }

    get disabledInput(){
        let result = true;
        console.log('disabledInput - rcordtype', this.order.RecordType.DeveloperName);
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || this.disabledSelectProcess){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledInput: ', result);
        return result;
    }

    handleDeliberateSelection(event){
        this.deliberation = event.currentTarget.value;
    }

    applySelectionLogic(selectedProcess){
        console.log('applySelectionLogic: ', JSON.stringify(selectedProcess));

        if(selectedProcess.RecordTypeName__c === 'HDT_RT_Attivazione')
        {
            // this.precheck = false;
            // this.compatibilita = true;
            // this.causale = 'E necessario effettuare un subentro';

            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';

            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_RiattivazioniNonMorose'){
            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_Subentro')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_SwitchIn')
        {
            // this.precheck = false;
            this.precheck = true;
            // this.compatibilita = false;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;

            this.showEsitoCheck = false;

        }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_AttivazioneConModifica')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_VAS')
        {
            this.selectedProcessObject.RecordTypeName__c = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_CambioOfferta')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_ScontiBonus')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_ConnessioneConAttivazione')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_TemporaneaNuovaAtt')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_CambioUso')
        // {
        //     this.precheck = true;
        //     this.compatibilita = true;
        //     this.causale = '';
        //     this.showDeliberation = false;
        // }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_Voltura'){
            this.selectedProcessObject.RecordTypeName__c = 'HDT_RT_Voltura';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 
        else{
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;

        }
    }

    incompatibilityfound(selectedProcess, compatibility){
        console.log('incompatibilityfound: ', JSON.stringify(selectedProcess));

        if(selectedProcess.RecordTypeName__c === 'HDT_RT_Attivazione')
        {
            // this.precheck = false;
            // this.compatibilita = true;
            // this.causale = 'E necessario effettuare un subentro';

            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;

            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_RiattivazioniNonMorose'){
            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_Subentro')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_SwitchIn')
        {
            // this.precheck = false;
            this.precheck = true;
            // this.compatibilita = false;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;

            this.showEsitoCheck = false;

        }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_AttivazioneConModifica')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_VAS')
        {
            this.selectedProcessObject.RecordTypeName__c = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_CambioOfferta')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_ScontiBonus')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_ConnessioneConAttivazione')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_TemporaneaNuovaAtt')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        // else if(selectedProcess.RecordTypeName__c === 'HDT_RT_CambioUso')
        // {
        //     this.precheck = true;
        //     this.compatibilita = false;
        //     this.causaleCompatibilita = compatibility;
        //     this.showDeliberation = false;
        // }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess.RecordTypeName__c === 'HDT_RT_Voltura'){
            this.selectedProcessObject.RecordTypeName__c = 'HDT_RT_Voltura';
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 

        else{
            this.precheck = true;
            this.compatibilita = false;
            this.causaleCompatibilita = compatibility;
            this.showDeliberation = false;
        }
    }

    handleSelectProcess(event){
        
        this.showEsitoCheck = false;

        // if(event.target.value == 'Prima Attivazione In delibera') {
        //     console.log('handleSelectProcess: ' + JSON.stringify(event.detail.value));
        //     this.deliberation = 'In Delibera';
        //     this.disabledDeliberation = true;
        // }

        // if(event.target.value == 'Prima Attivazione Fuori delibera') {
        //     console.log('handleSelectProcess: ' + JSON.stringify(event.detail.value));
        //     this.deliberation = 'Fuori delibera';
        //     this.disabledDeliberation = true;
        // }

        this.selectedProcessObject = this.processesReference.filter(el =>  el.ProcessName__c === event.target.value)[0];

        this.pickValue = event.target.value;
        this.startCheckContendibilita();


    }

    goToNextStep(extraParams){
        this.loaded = false;

        if(Object.keys(extraParams).length === 0) {
            extraParams = {};
        }

        //EVERIS
        console.log('OrderId--> '+this.order.Id);
        //EVERIS

        //EVERIS: Aggiunta variabile Order

        next({order: this.order,orderId: this.order.Id, selectedProcessObject: this.selectedProcessObject, deliberate: this.deliberation, extraParams: extraParams, srRequest: this.serviceRequest}).then(data =>{
            if(data != '' && data != this.order.OrderNumber){
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Processo incompatibile!',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);

                this.incompatibilityfound(this.selectedProcessObject, data);
                this.loaded = true;
            }else{
                this.loaded = true;
                this.dispatchEvent(new CustomEvent('refreshorderchild'));
            }

        }).catch(error => {
            this.loaded = true;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext(){
        //@Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
        /**
         * La chiamata al credit check va eseguita per queste condizioni
         * HDT_RT_Subentro , HDT_RT_AttivazioneConModifica, HDT_RT_SwitchIn (solo se process_type diverso da Switch In Ripristinatorio), 
         * HDT_RT_ConnessioneConAttivazione, HDT_RT_TemporaneaNuovaAtt, HDT_RT_Voltura, 
         * HDT_RT_VAS (Solo Se: OrderReference__c <> null & ContractReference <> null)
         */
         console.log('****12');
         console.log('# SelectedProcess.RecordType >>> ' + this.selectedProcessObject.RecordTypeName__c === 'HDT_RT_VAS');
         console.log('# Quote Condition >>> ' + this.order.SBQQ__Quote__c != this.order?.OrderReference__r?.SBQQ__Quote__c);
         console.log('# RecordType condition >>> ' + ['HDT_RT_Voltura','HDT_RT_VolturaConSwitch','HDT_RT_Subentro', 'HDT_RT_AttivazioneConModifica', 'HDT_RT_ConnessioneConAttivazione', 'HDT_RT_TemporaneaNuovaAtt', 'HDT_RT_SwitchIn', 'HDT_RT_Attivazione'].includes(this.selectedProcessObject.RecordTypeName__c));
         console.log('# ProcessType Conditio >>> ' + this.selectedProcessObject.processType !== 'Switch in Ripristinatorio');
         console.log('# Full Condition >>> ' + (this.selectedProcessObject.RecordTypeName__c === 'HDT_RT_VAS' && this.order.SBQQ__Quote__c != this.order?.OrderReference__r?.SBQQ__Quote__c ) || (['HDT_RT_Voltura','HDT_RT_VolturaConSwitch','HDT_RT_Subentro', 'HDT_RT_AttivazioneConModifica', 'HDT_RT_ConnessioneConAttivazione', 'HDT_RT_TemporaneaNuovaAtt', 'HDT_RT_SwitchIn', 'HDT_RT_Attivazione'].includes(this.selectedProcessObject.RecordTypeName__c) && this.selectedProcessObject.processType !== 'Switch in Ripristinatorio'));
        //if((this.selectedProcessObject.RecordTypeName__c === 'HDT_RT_VAS' && (this.order.OrderReferenceNumber == null || this.order.OrderReferenceNumber === undefined) && (this.order.ContractReference__c == null || this.order.ContractReference__c === undefined)) || (['HDT_RT_Voltura', 'HDT_RT_Subentro', 'HDT_RT_AttivazioneConModifica', 'HDT_RT_ConnessioneConAttivazione', 'HDT_RT_TemporaneaNuovaAtt', 'HDT_RT_SwitchIn', 'HDT_RT_Attivazione'].includes(this.selectedProcessObject.RecordTypeName__c) && this.selectedProcessObject.processType != 'Switch in Ripristinatorio')){
        console.log('# ProcessType >>> ' + this.selectedProcessObject.processType);
        if( (['HDT_RT_VAS','HDT_RT_Voltura','HDT_RT_VolturaConSwitch','HDT_RT_Subentro', 'HDT_RT_AttivazioneConModifica', 'HDT_RT_ConnessioneConAttivazione', 'HDT_RT_TemporaneaNuovaAtt', 'HDT_RT_SwitchIn', 'HDT_RT_Attivazione'].includes(this.selectedProcessObject.RecordTypeName__c) && this.selectedProcessObject.ProcessName__c != 'Switch in Ripristinatorio')){
            this.callCreditCheckSAP();
        }
        console.log('****13');
        

        let extraParams = {};

        if(this.order.ServicePoint__r !== undefined){
            extraParams['servicePointType'] = this.order.ServicePoint__r.RecordType.DeveloperName;
        }

        if(this.order.ProcessType__c === 'Switch in Ripristinatorio'){
            extraParams['switchInRipristinatorio'] = 'true';
        }
        console.log('****1');
        if (this.showDeliberation === true) {
            console.log('****2');
            if (this.deliberation !== '') {
                console.log('****4');
                this.goToNextStep(extraParams);
                this.disabledDeliberation = true;
            } else {
                console.log('****5');
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Devi compilare il campo delibera.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        } else {
            console.log('****3');
            this.goToNextStep(extraParams);
        }

    }

    connectedCallback(){
        console.log('this.order: ', JSON.parse(JSON.stringify(this.order)));

        console.log('CallBack start');
        this.deliberation = this.order.Deliberation__c;

        if (this.order.ServicePoint__c !== null && this.order.ServicePoint__c !== undefined){
            this.service = this.order.ServicePoint__r.CommoditySector__c;
            console.log('COMMODITY: ' + this.service);
        }

        if (this.order.RecordType.DeveloperName === 'HDT_RT_Default') {
            console.log('enter default');
            init({order: this.order}).then(data =>{
                this.loaded = true;
                console.log('initProcesses: ' + JSON.stringify(data));
    
                this.processesReference = data;

                this.options = [];

                data.forEach(el => {
                    this.options.push({label: el.ProcessName__c, value: el.ProcessName__c});
                });
    
                if (this.options.length === 1) {
                    this.selectedProcessObject = this.processesReference[0];
                    this.value = this.selectedProcessObject.ProcessName__c;
                    this.disabledSelectProcess = true;
                    this.pickValue = this.value;
                    this.startCheckContendibilita();
                    // this.checkCompatibilityProcess();
                }
    
                if (this.options.length === 0) {
                    console.log('# Vas Subtype >>> ' + this.order.VasSubtype__c );
                    if(this.order.IsVAS__c || this.order.VasSubtype__c === 'Analisi Consumi'){
                        this.options.push({label: 'VAS', value: 'VAS'});
                        this.selectedProcessObject = {ProcessName__c: 'VAS', RecordTypeName__c: 'HDT_RT_VAS'}
                        console.log('ProcessObj >>> ' + JSON.stringify(this.selectedProcessObject));
                        this.value = this.selectedProcessObject.ProcessName__c;
                        this.disabledSelectProcess = true;
                        this.pickValue = this.value;
                        this.startCheckContendibilita();
                        // this.checkCompatibilityProcess();
                    }
                }
                if(this.order.IsVAS__c){
                    getConsumptionAnnualForVas({orderId: this.order.Id}).then(data =>{
                       this.consumptionAnnualForVas = data; 
                    }).catch(error => {
                        console.log(error.body.message);                    
                    });
                }
            }).catch(error => {
                this.loaded = true;
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else {
            console.log('enter with value');
            this.options = [];
            // fix LG 2009 richiesta da CZ da Room
            let label = new RegExp("^Prima Attivazione").test(this.order.ProcessType__c) ? this.order.ProcessType__c == 'Prima Attivazione con modifica' ? this.order.ProcessType__c : "Prima Attivazione" : this.order.ProcessType__c;
            this.options.push({label: label, value: this.order.ProcessType__c});
            this.selectedProcessObject = {ProcessName__c: this.order.ProcessType__c, recordType: this.order.RecordType.DeveloperName}
            this.value = this.selectedProcessObject.ProcessName__c;
            // this.checkCompatibilityProcess();
            this.pickValue = this.value;
            this.startCheckContendibilita();
        }

        this.creditCheckFields = [
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
        ];
        
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

    // START @Picchiri 07/06/21 Credit Check
    async callCreditCheckSAP(){
        this.loading = true;
        var wrp = this.getRequest();
        
        console.log('connectedCallback wrp ---> ');
        console.log(JSON.parse(JSON.stringify(wrp)));

        let isVasAndCommodity = false;

        try {
            isVasAndCommodity = await checkVasAndCommodity({ ord: this.order, recordTypeName: this.selectedProcessObject.RecordTypeName__c });
            console.log('isVasAndCommodity: ' + isVasAndCommodity);
        } catch (error) {
            console.log(JSON.parse(JSON.stringify(error)));
            let toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error,
                variant: 'error', 
                mode:'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            return;
        }

        if(!isVasAndCommodity){
            callServiceCreditCheck({req: wrp})
            .then(result => {
                console.log('result callServiceCreditCheck ---> : ');
                console.log(JSON.parse(JSON.stringify(result)));

                if(result.status == 'failed'){
                    /*let message = Object.values(result.errorDetails[0].message).reduce((testoFinale, elem ,index, array)=>{
                        return `${testoFinale}\n${elem}`;
                    }, result.errorDetails[0].code);
                    console.log(message);*/ //to log decomment HDT_WS_CreditCheckResponse map string string
                    /*let toastErrorMessage = new ShowToastEvent({
                        title: 'CreditCheck KO',
                        message: message,
                        variant: 'warning', 
                        mode:'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);*/
                    //throw {body:{message:result.errorDetails[0].code + ' ' + result.errorDetails[0].message}}
                }
                

                //this.restryEsitiCreditCheck();
                this.loading = false;
            })
            .catch(error => {
                debugger;
                console.log('error callServiceCreditCheck error ---> : ');
                console.log(JSON.parse(JSON.stringify(error)));
                let toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error', 
                    mode:'sticky'
                });
                
                this.dispatchEvent(toastErrorMessage);
                this.loading = false;
            });
        }
    }

    getRequest(){ 
        var typeOfCommodity = 'ENERGIAELETTRICA';
        let separator = this.order.Account.CustomerCode__c ? ' ' : ',';
        let companyName = this.order.Account.FirstName__c? this.order.Account.FirstName__c+separator+this.order.Account.LastName__c : this.order.Account.LastName__c;
        let companyGroup;
        var secondaryCustomerId = null;
        var bpType = null;
        var operation = null;
        var market = null; 
        var offerType = null; 
        let bpClass = null;
        console.log("RecordType: " + this.order.RecordType.DeveloperName);
        console.log("typeOfCommodity: " + typeOfCommodity);
        var fiscalData = null;

        if(this.selectedProcessObject.RecordTypeName__c !== 'HDT_RT_VAS'){
            if(this.order.ServicePoint__r.CommoditySector__c == 'Gas'){
                typeOfCommodity = 'GAS';
            }
        }
        if(this.order.SalesCompany__c !== undefined){
            companyGroup = this.order.SalesCompany__c;
        }
        if(this.order.Account.VATNumber__c !== undefined){
            secondaryCustomerId = this.order.Account.VATNumber__c;
        }
        if(this.order.Account.CustomerType__c !== undefined){
            bpType = this.order.Account.CustomerType__c;
        }
        if( this.selectedProcessObject.ProcessName__c !== undefined){
            operation = this.selectedProcessObject.ProcessName__c;
        }
        if(this.order.Market__c !== undefined){
            market = this.order.Market__c;
        }
        if(this.order.Catalog__c !== undefined){
            offerType = this.order.Catalog__c;
        }
        if(new RegExp("D[0-9] - ").test(this.order.Account.CustomerMarking__c)){
            bpClass=this.order.Account.CustomerMarking__c.replace(new RegExp("D[0-9] - "), "");
        }else{
            bpClass=this.order.Account.CustomerMarking__c;
        }
        console.log("typeOfCommodity: " + typeOfCommodity);
        console.log("this.selectedProcessObject: " + JSON.stringify(this.selectedProcessObject));
        
        let data = {
            sistema: "eEnergy",
            caso:"Transazionale",
            crmEntity:"Order",
            crmId:this.order.Id.slice(0,15),
            userId: this.order.CreatedById,
            activationUser:"AccountCommercialePRM", //this.order.Owner.Username (parte prima @)
            account:"AccountCommercialePRM", //this.order.Owner.Username (parte prima @)
            jobTitle:this.order.ChannelTransCode__c,
            internalCustomerId:this.order.Account.CustomerCode__c ? this.order.Account.CustomerCode__c : this.order.Account.Id.slice(7,15),
            companyName:companyName,
            externalCustomerId:this.order.Account.FiscalCode__c? this.order.Account.FiscalCode__c : this.order.Account.VATNumber__c,
            secondaryCustomerId:secondaryCustomerId,
            //bpClass:bpClass,
            bpClass:this.order.Account.CustomerMarking__c,
            bpCategory:this.order.Account.Category__c,
            bpType:bpType,
            customerType:"CT0", //da definire campo SF con business            
            operation:operation,
            companyGroup:companyGroup,//this.order.SalesCompany__c
            market:market,
            offerType:offerType,
            details:[{
                commodity:typeOfCommodity
            }]		
        }
        console.log("this.2"); 

        if(this.selectedProcessObject.RecordTypeName__c !== 'HDT_RT_VAS'){
            data["address"] = this.order.ServicePoint__r.SupplyStreetName__c;
            data["municipality"] = this.order.ServicePoint__r.SupplyCity__c;
            data["district"] = this.order.ServicePoint__r.SupplyProvince__c;
            data["postCode"] = this.order.ServicePoint__r.SupplyPostalCode__c;

            data["details"][0] = { ...data["details"][0], "annualConsumption":this.order.ServicePoint__r.AnnualConsumption__c};
        }
        else{
            if(this.consumptionAnnualForVas != null){
                data["details"][0] = { ...data["details"][0], "annualConsumption":this.consumptionAnnualForVas};
            }
        }
        console.log("this.3"); 

        if((this.selectedProcessObject.RecordTypeName__c === 'HDT_RT_Subentro' || this.selectedProcessObject.RecordTypeName__c === 'HDT_RT_Voltura' || this.checkOutcomingVolturaWithSwitch(this.selectedProcessObject.RecordTypeName__c, this.order) ) && (this.order.Account.Id != this.order.ServicePoint__r?.Account__r?.Id) ){
            console.log("this.31:" + JSON.stringify(this.order.Account.RecordType.DeveloperName)); 
            console.log("this.310:" + JSON.stringify(this.order.ServicePoint__r)); 
            if(this.order.ServicePoint__r?.Account__r?.RecordType?.DeveloperName === 'HDT_RT_Residenziale'){
                console.log("this.32:"); 
                fiscalData = this.order.ServicePoint__r?.Account__r?.FiscalCode__c;
            }else if(this.order.ServicePoint__r?.Account__r?.VATNumber__c != null){
                console.log("this.33:"); 
                fiscalData = this.order.ServicePoint__r?.Account__r?.VATNumber__c;
            }
            console.log("this.34"); 
            
            data["bpAlternative"] = this.order.ServicePoint__r?.Account__r?.CustomerCode__c;
            //ticket 905174C email del 02/11/2022
            //data["alternativeCustomerId"] = fiscalData;
        }
        console.log("this.4"); 
        console.log("@@@@request --> " + JSON.stringify(data)); 
        return data; 
    }
    // END @Picchiri 07/06/21 Credit Check
    checkCompatibilityProcess(){
        this.loaded = false;
        console.log('**********:12' + this.order.AccountId);
        let processType = this.selectedProcessObject.ProcessName__c;
        if (processType === undefined) {
            processType = this.order.ProcessType__c;
        }
        let sRequest= {
            'servicePoint': this.order.ServicePoint__c,
            'servicePointCode': this.order.ServicePoint__r?.ServicePointCode__c,
            'status': this.order.Status,
            'account' : this.order.AccountId,
            'order': this.order.Id,
            'commoditySector': this.order.ServicePoint__r?.CommoditySector__c,
            'type': 'Order',
            'processType' : processType
        };
        if(this.selectedProcessObject.ProcessName__c=="VAS"){
            sRequest["isBillableVas"]=this.order.IsBillableVas__c;
            console.log('#VasSubType Precheck >>> ' + this.order.VasSubtype__c);
            if(this.order.VasSubtype__c === 'Analisi Consumi')
            {
                console.log('#CommoditySector >>> ' + sRequest["commoditySector"]);
                let processType = sRequest["commoditySector"] === 'Energia Elettrica' ? 'Aggiunta Sconti o Bonus VAS Ele' : 'Aggiunta Sconti o Bonus VAS Gas'
                console.log('#ProcessType Precheck Analisi Consumi >>> ' + processType);
                sRequest["processType"] = processType;
            }
            console.log('#ServiceRequest >>> ' + JSON.stringify(sRequest));
        }
        checkCompatibility({servReq: sRequest}).then(data =>{
            if(data.compatibility == '' || data.compatibility == this.order.OrderNumber){
                this.applySelectionLogic(this.selectedProcessObject);
                this.serviceRequest= data.ServiceRequest;
            }else{
                this.incompatibilityfound(this.selectedProcessObject, data.compatibility);
            }
            this.loaded = true;

        }).catch(error => {
            this.loaded = true;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
            this.loaded = true;
        });
    }

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

    async retryEsitiCreditCheck(){        

        try {
            this.loaded = false;
            this.creditCheckResult = await retrieveOrderCreditCheck({idOrder: this.order.Id});
            this.loaded = true;

            console.log('this.creditCheckResult: ' + JSON.stringify(this.creditCheckResult));

            for(let j = 0;  j < this.creditCheckFields.length; j++){
                if(this.creditCheckFields[j].apiname == 'IncomingCreditCheckResult__c'){
                    this.creditCheckFields[j].value = this.creditCheckResult['IncomingCreditCheckResult__c']
                }
                else if(this.creditCheckFields[j].apiname == 'OutgoingCreditCheckResult__c'){
                    this.creditCheckFields[j].value = this.creditCheckResult['OutgoingCreditCheckResult__c'];
                }
                else if (this.creditCheckFields[j].apiname == 'CreditCheckDescription__c'){
                    this.creditCheckFields[j].value = this.creditCheckResult['CreditCheckDescription__c'];
                }
            }
          } catch(err) {
            console.log(err);
        }
        
    }

    @api
    async executeCreditCheckPoll(){
        console.log('hdtChildOrderProcessPrecheck - executeCreditCheckPoll - START');

        const setAsyncTimeout = (cb, timeout = 0) => new Promise(resolve => {
            setTimeout(() => {
                cb();
                resolve();
            }, timeout);
        });

        let count = 1;
        let time = 18000;

        console.log('executePoll - this.order.IncomingCreditCheckResult__c: ' + JSON.stringify(this.order.IncomingCreditCheckResult__c));
        console.log('executePoll - this.order.OutgoingCreditCheckResult__c: ' + JSON.stringify(this.order.OutgoingCreditCheckResult__c));
        console.log('executePoll - this.order.CreditCheckDescription__c: ' + JSON.stringify(this.order.CreditCheckDescription__c));
        console.log('executePoll - this.creditCheckResult: ' + JSON.stringify(this.creditCheckResult));

        while(count <= 8
            && !(this.order.IncomingCreditCheckResult__c !== undefined || this.order.OutgoingCreditCheckResult__c !== undefined || this.order.CreditCheckDescription__c !== undefined)
            && !(this.creditCheckResult.IncomingCreditCheckResult__c !== undefined || this.creditCheckResult.OutgoingCreditCheckResult__c !== undefined || this.creditCheckResult.CreditCheckDescription__c !== undefined)
            ){

            if (count > 1) {
                time = 3000;
            }

            await setAsyncTimeout(() => {
                this.retryEsitiCreditCheck();
            }, time);

            console.log('OK poll! ' + count + ' ' + time);
            count++;
        }

        console.log('hdtChildOrderProcessPrecheck - executeCreditCheckPoll - END');
    }

    /**@Author: Salvatore Alessandro Sarà 01/11/2021
     * Richiamo Servizio per check contendibilità
     **/ 

    startCheckContendibilita(){
        console.log('PickList Value: ' + this.pickValue);
        console.log('Service Value: ' + this.service);
        console.log('isTransition__c: ' + this.order.isTransition__c);
        if((this.pickValue === 'Prima Attivazione' || this.pickValue === 'Subentro Gas') && this.service === 'Gas' && this.order.isTransition__c != true) {
            console.log('Caso checkContendibilitaPodPdr');
            this.checkContendibilitaPodPdr();
        }else{
            console.log('Caso checkCompatibilityProcess');
            this.checkCompatibilityProcess();
        }
    }

    checkContendibilitaPodPdr(){
        this.loaded = false;
        let array = [];
        checkContendibilita({order: this.order})
            .then((result) => {
                array = result;
                console.log('checkContendibilita - Esito: ' + array['ESITO']);
                console.log('checkContendibilita - Codice Scarto: ' + array['DES_ERR_AEEG']);
                this.precheck = array['ESITO'];
                this.causaleContendibilita = array['DES_ERR_AEEG'];
                this.loaded = true;
                this.showEsitoCheck = true;

                if(this.precheck === true){
                    this.checkCompatibilityProcess();
                }
            })
            .catch(error => {
                this.loaded = true;
                console.log('ERROR checkContendibilita: ' + error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });
    }

    checkOutcomingVolturaWithSwitch(recordTypeName,order){
        let response  = (recordTypeName === 'HDT_RT_VolturaConSwitch' && order.ServicePoint__r && order.ServicePoint__r.Account__r && order.ServicePoint__r.Account__r.Id);
		if (response){
			console.log('@@@@ checkOutcomingVolturaWithSwitch --> ' + true);
		}else{
			console.log('@@@@ checkOutcomingVolturaWithSwitch --> ' + false);
		}
        return response;
    }
}