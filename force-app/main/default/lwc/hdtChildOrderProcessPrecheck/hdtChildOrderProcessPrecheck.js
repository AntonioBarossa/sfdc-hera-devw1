import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOptions from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.getOptions';
import next from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.next';

// @Picchiri 07/06/21 Credit Check Innesco per chiamata al ws
import callServiceCreditCheck from '@salesforce/apex/HDT_WS_CreditCheck.callService';
export default class hdtChildOrderProcessPrecheck extends LightningElement {
    @api order;
    precheck = false;
    causale = '';
    causaleCompatibilita = '';
    selectedProcess = '';
    compatibilita = false;
    loaded = true;
    deliberation = '';
    showDeliberation = false;
    disabledDeliberation = false;
    showEsitoCheck = false;
    vasAmendDisabledInput = false;
    SwitchInRipristinatorioDisabledInput = false;
    cambioOffertaInput = false;
    
    get value(){
        let result = '';
        console.log('**************************************** ', this.order.RecordType.DeveloperName);
        //COMMENTATO POICHE GENERAVA ERRORE
        if (this.order.RecordType.DeveloperName !== 'Default') {
            if(this.order.ProcessType__c === 'Switch in Ripristinatorio'){
                result = 'HDT_RT_SwitchIn';
            }
            else if (this.order.ProcessType__c === 'Cambio Offerta') {
                result = 'HDT_RT_CambioOfferta';
            }
            else if(this.order.SBQQ__Quote__r.IsVAS__c){
                result = 'HDT_RT_VAS';
            } else if(this.order.SBQQ__Quote__r.AmendmentAllowed__c) {
                result = 'HDT_RT_ScontiBonus';
            } else {
                result = this.order.RecordType.DeveloperName;
            }
            this.applySelectionLogic(result);
        } else {
            result = '';
        }
        //COMMENTATO POICHE GENERAVA ERRORE
        return result;
    }

    get options(){

        let records = [];

        //COMMENTATO POICHE GENERAVA ERRORE
        if(this.order.ProcessType__c === 'Switch in Ripristinatorio'){
            records = [
                {"label":"SwitchIn","value":"HDT_RT_SwitchIn"}
            ]
        }
        else if(this.order.ProcessType__c === 'Cambio Offerta'){
            records = [
                {"label":"Cambio Offerta","value":"HDT_RT_CambioOfferta"}
            ]
        }
        else if(this.order.SBQQ__Quote__r.IsVAS__c){
            records = [
                {"label":"VAS","value":"HDT_RT_VAS"}
            ]
        } else if(this.order.SBQQ__Quote__r.AmendmentAllowed__c){
            records = [
                {"label":"Aggiunta Sconti o Bonus VAS","value":"HDT_RT_ScontiBonus"}
            ]
        } else {
        //COMMENTATO POICHE GENERAVA ERRORE
            records = [
                {"label":"Attivazione","value":"HDT_RT_Attivazione"},
                {"label":"Attivazione con Modifica","value":"HDT_RT_AttivazioneConModifica"},
                // {"label":"Riattivazione Non Morose","value":"HDT_RT_RiattivazioniNonMorose"},
                {"label":"Subentro","value":"HDT_RT_Subentro"},
                {"label":"SwitchIn","value":"HDT_RT_SwitchIn"},
                //INIZIO SVILUPPI VOLTURA EVERIS
                {"label":"Voltura","value":"HDT_RT_Voltura"}
                //FINE SVILUPPI VOLTURA EVERIS
                // {"label":"SwitchIn con Voltura Tecnica","value":"HDT_RT_SwitchInVolturaTecnica"}
                
            ]
        //COMMENTATO POICHE GENERAVA ERRORE    
        }
       //COMMENTATO POICHE GENERAVA ERRORE    

        return records;
    }

    handleShowDeliberation(selectedProcess){
        this.showDeliberation = (selectedProcess === 'HDT_RT_Attivazione' || selectedProcess === 'HDT_RT_RiattivazioniNonMorose');
        this.disabledDeliberation = this.order.Deliberation__c !== '';
    }

    get disabledNext(){
        let result = true;
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || (this.selectedProcess === '')){
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
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || this.vasAmendDisabledInput || this.SwitchInRipristinatorioDisabledInput || this.cambioOffertaInput){
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
        console.log('applySelectionLogic: ', selectedProcess);

        // this.handleShowDeliberation(selectedProcess);

        if(selectedProcess === 'HDT_RT_Attivazione')
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
        else if(selectedProcess === 'HDT_RT_RiattivazioniNonMorose'){
            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess === 'HDT_RT_Subentro')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_SwitchIn')
        {
            // this.precheck = false;
            this.precheck = true;
            // this.compatibilita = false;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;

            this.showEsitoCheck = false;

            if (this.order.ProcessType__c === 'Switch in Ripristinatorio') {
                this.selectedProcess = 'HDT_RT_SwitchIn';
            }
        }
        else if(selectedProcess === 'HDT_RT_AttivazioneConModifica')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_VAS')
        {
            this.selectedProcess = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_CambioOfferta')
        {
            this.selectedProcess = 'HDT_RT_CambioOfferta';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_ScontiBonus')
        {
            this.selectedProcess = 'HDT_RT_ScontiBonus';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess === 'HDT_RT_Voltura'){
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 


    }

    handleSelectProcess(event){
        this.selectedProcess = event.target.value;
        this.applySelectionLogic(this.selectedProcess);
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
        next({order: this.order,orderId: this.order.Id, selectedProcess: this.selectedProcess, deliberate: this.deliberation, extraParams: extraParams}).then(data =>{
            this.loaded = true;
            this.dispatchEvent(new CustomEvent('refreshorderchild'));

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
        // SE VAS al momento non innescare il credit check
        if(this.selectedProcess !== 'HDT_RT_VAS'){
            this.callCreditCheckSAP();
        }
        

        let extraParams = {};

        if(this.order.ServicePoint__r !== undefined){
            extraParams['servicePointType'] = this.order.ServicePoint__r.RecordType.DeveloperName;
        }

        if(this.order.ProcessType__c === 'Switch in Ripristinatorio'){
            extraParams['switchInRipristinatorio'] = 'true';
        }

        if (this.showDeliberation === true) {
            if (this.deliberation !== '') {
                this.goToNextStep(extraParams);
            } else {
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Devi compilare il campo delibera.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        } else {
            this.goToNextStep(extraParams);
        }

    }

    connectedCallback(){
        console.log('this.order: ', JSON.parse(JSON.stringify(this.order)));

        console.log('CallBack start');

        if(this.order.SBQQ__Quote__r.IsVAS__c || this.order.SBQQ__Quote__r.AmendmentAllowed__c){
            this.showEsitoCheck = false;
            this.vasAmendDisabledInput = true;
        }
        
        if (this.order.ProcessType__c === 'Switch in Ripristinatorio') {
            this.SwitchInRipristinatorioDisabledInput = true;
        }

        if (this.order.ProcessType__c === 'Cambio Offerta') {
            this.cambioOffertaInput = true;
        }

        console.log('CallBack end');

    }

    // START @Picchiri 07/06/21 Credit Check
    callCreditCheckSAP(){
        this.loading = true;
        var wrp = this.getRequest();
        
        console.log('connectedCallback wrp ---> ');
        console.log(JSON.parse(JSON.stringify(wrp)));
                
        callServiceCreditCheck({wrpVals:JSON.stringify(wrp)})
        .then(result => {
            console.log('result callServiceCreditCheck ---> : ');
            console.log(JSON.parse(JSON.stringify(result)));

            if(result.status == 'failed'){
                throw {body:{message:result.errorDetails[0].code + ' ' + result.errorDetails[0].message}}
            }

            //this.restryEsitiCreditCheck();
            this.loading = false;
        })
        .catch(error => {
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
        })        
    }

    getRequest(){
        var typeOfCommodity = this.order.ServicePoint__r.CommoditySector__c;
        var fiscalData = null;
        if(typeOfCommodity == 'Energia Elettrica'){
            typeOfCommodity = 'ENERGIAELETTRICA';
        }
        if(typeOfCommodity == 'Gas'){
            typeOfCommodity = 'GAS';
        }
        
        let data = {
            sistema: "eEnergy",
            caso:"Transazionale",
            crmEntity:"Order",
            crmId:this.order.OrderNumber,
            userId: this.order.CreatedById,
            activationUser:"AccountCommercialePRM",
            account:"AccountCommercialePRM",
            jobTitle:this.order.Channel__c,
            internalCustomerId:this.order.Account.CustomerCode__c,
            companyName:this.order.SalesCompany__c,
            externalCustomerId:this.order.Account.FiscalCode__c,
            secondaryCustomerId:this.order.Account.VATNumber__c,
            bpClass:this.order.Account.CustomerMarking__c,
            bpCategory:this.order.Account.Category__c,
            bpType:this.order.Account.CustomerType__c,
            customerType:"CT0",                                                 //da definire campo SF con business
            address:this.order.ServicePoint__r.SupplyStreetName__c,
            municipality:this.order.ServicePoint__r.SupplyCity__c,
            district:this.order.ServicePoint__r.SupplyProvince__c,
            postCode:this.order.ServicePoint__r.SupplyPostalCode__c,
            operation:this.order.ProcessType__c,
            companyGroup:"Hera S.p.A.",
            market:this.order.Market__c,
            offerType:this.order.Catalog__c,
            details:[{
                commodity:typeOfCommodity,
                annualConsumption:this.order.ServicePoint__r.AnnualConsumptionStandardM3__c // mettere lo standard
            }]		
        }

        if(this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
            
            if(this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale'){
                fiscalData = this.order.ServicePoint__r.Account__r.FiscalCode__c;
            }else if(this.order.ServicePoint__r.Account__r.VATNumber__c != null){
                fiscalData = this.order.ServicePoint__r.Account__r.VATNumber__c;
            }
            
            data["bpAlternative"] = this.order.ServicePoint__r.Account__r.CustomerCode__c; //!null
            data["alternativeCustomerId"] = fiscalData;            
        }

        return data; 
    }
    // END @Picchiri 07/06/21 Credit Check
}