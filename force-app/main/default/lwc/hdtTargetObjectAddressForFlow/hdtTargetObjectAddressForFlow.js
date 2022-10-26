import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE} from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";

export default class HdtTargetObjectAddressForFlow extends LightningElement {

    @api cancelCase;
    @api theCase;
    @api interviewId;
    @api hideNavigationButtons = false;

    stopRendered=false;//boolean to check if set indirizzi

    //subscribe
    @wire(MessageContext)
	messageContext;
    //subscribe

    @api
    validate() {
        console.log("event catched   "+this.eventButton);
        this.unsubscribeToMessageChannel();
        this.cancelCase = 'cancel' == this.eventButton ? true : this.cancelCase;
        if(!this.cancelCase){
            let address = this.getAddress();
            let validity = this.validateAddress(address);
            if (validity.isValid === true) {
                this.populateCase(address);
                //lanciare evento per inviare oggetto theCase;
                //integrare coi campi del BP (non fare update diretto da apex, torna un nuovo case)
                //Gestire salva in bozza in cui saltiamo i controlli dell'input ma poi siamo anche in grado di riprenderli (sfrutta funzionalità clona bp)
                //anche per cb indirizzi, abilita sempre il tasto per verifica indirizzi
            }
            return validity;
        }else{
            return {isValid: true};
        }
    }

    @api
    alert(title,msg,variant){
        console.log("alert: "+msg);
        const event = ShowToastEvent({
            title: title,
            message:  msg,
            variant: variant
        });
        dispatchEvent(event);
    }

    subscribeMC() {
		// recordId is populated on Record Pages, and this component
		// should not update when this component is on a record page.
        this.subscription = subscribe(
            this.messageContext,
            BUTTONMC,
            (mc) => {if(this.interviewId==mc.sessionid) this.eventButton = mc.message},
            //{ scope: APPLICATION_SCOPE }
        );
		// Subscribe to the message channel
	}

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    validateAddress(address) {
        console.log('validateAddress START');
        let errorMessages = [];
        let concatAddressErrorFields = '';

        //Validate address
        if(!address['Indirizzo Estero']){
            console.log('entra in if ind estero');
            if (!address['Flag Verificato']) {
                console.log('entra in flag verificato false ');
                //this.saveErrorMessage.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
                errorMessages.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
            }
        } 
        console.log('entra in else ind estero ');
        console.log('### Address >>> ' +JSON.stringify(address));
        if (address['Stato'] === undefined || address['Stato'] === '') {
            concatAddressErrorFields = concatAddressErrorFields.concat('Stato, ');
        }
        if (address['Provincia'] === undefined || address['Provincia'] === '') {
            concatAddressErrorFields = concatAddressErrorFields.concat('Provincia, ');
        }
        if (address['Comune'] === undefined || address['Comune'] === '') {
            concatAddressErrorFields = concatAddressErrorFields.concat('Comune, ');
        }
        if (address['Via'] === undefined || address['Via'] === '') {
            concatAddressErrorFields = concatAddressErrorFields.concat('Via, ');
        }
        if (address['Civico'] === undefined || address['Civico'] === '') {
            concatAddressErrorFields = concatAddressErrorFields.concat('Civico, ');
        }
        if (address['CAP'] === undefined || address['CAP'] === '') {
            concatAddressErrorFields = concatAddressErrorFields.concat('CAP, ');
        }
        if (concatAddressErrorFields !== '') {
            errorMessages.push('Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2));
        }
               

        if (errorMessages.length==0) {
            return {
                isValid: true
            };
        }
        else {
            return {
                isValid: false,
                errorMessage: errorMessages.join("; ")
            };
        }
    }

    renderedCallback(){
        //init component indirizzi
        if(this.stopRendered)   return;
        const lwcIndirizzi =this.template.querySelector("c-hdt-target-object-address-fields");
        if(lwcIndirizzi==null)  return;
        this.stopRendered=true;
        let wrapperAddress = {};
        if(this.theCase["InvoicingCity__c"] != undefined){
            wrapperAddress['Comune'] = this.theCase["InvoicingCity__c"];
        }else{
            return;
        }
        if(this.theCase["InvoicingStreetName__c"] != undefined){
            wrapperAddress['Via'] = this.theCase["InvoicingStreetName__c"];
        }
        if(this.theCase["InvoicingPostalCode__c"] != undefined){
            wrapperAddress['CAP'] = this.theCase["InvoicingPostalCode__c"];
        }
        if(this.theCase["InvoicingCountry__c"] != undefined){
            wrapperAddress['Stato'] = this.theCase["InvoicingCountry__c"];
        }
        if(this.theCase["InvoicingProvince__c"] != undefined){
            wrapperAddress['Provincia'] = this.theCase["InvoicingProvince__c"];
        }
        if(this.theCase["InvoicingStreetNumberExtension__c"]  != undefined){
            wrapperAddress['Estens.Civico'] = this.theCase["InvoicingStreetNumberExtension__c"] ;
        }
        if(this.theCase["InvoicingStreetNumber__c"] != undefined){
            wrapperAddress['Civico'] = this.theCase["InvoicingStreetNumber__c"];
        }
        if(this.theCase["InvoicingPlace__c"] != undefined){
            wrapperAddress['Localita'] = this.theCase["InvoicingPlace__c"];
        }
        if(this.theCase["InvoicingStreetCode__c"] != undefined){
            wrapperAddress['Codice Via Stradario SAP'] = this.theCase["InvoicingStreetCode__c"];
        }
        if(this.theCase["InvoicingCityCode__c"] != undefined){
            wrapperAddress['Codice Comune SAP'] = this.theCase["InvoicingCityCode__c"];
        }
        //wrapperAddress["AbilitaVerifica"]=false;//abilita il tasto verifica
        wrapperAddress["Flag Verificato"]=true;//questi due abilitano la check "verificata"
        wrapperAddress["FlagVerificato"]=true;//questi due abilitano la check "verificata"
        console.log('wrapper addr'+JSON.stringify(wrapperAddress));
        const targetFields = this.template.querySelector("c-hdt-target-object-address-fields");
        //getInstanceWrapObject()
        targetFields.getInstanceWrapObjectBilling(wrapperAddress);
        //targetFields.handleAddressVerification();
    }

    @api
    getAddress() {
        let address = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        if(!address["Stato"])
        {
            console.log('### Adding Stato ###')
            address['Stato']='ITALIA';
        }
        if (address['Stato']=='Italy' || address['Stato']=='Italia'){
            address['Stato']='ITALIA';
        }
        address['Flag Verificato']=true;
        console.log('### Get Address >>> ' + JSON.stringify(address));
        return address;
    }


    @api
    prepopulateAddress(wrapperAddress)
    {
        const targetFields = this.template.querySelector("c-hdt-target-object-address-fields");
        targetFields.getInstanceWrapObjectBilling(wrapperAddress);
    }

    populateCase(address){
        this.theCase={...this.theCase};
        this.theCase["InvoicingStreetName__c"] = address['Via'];
        this.theCase["InvoicingCity__c"] = address['Comune'];
        this.theCase["InvoicingPostalCode__c"] = address['CAP'];
        this.theCase["InvoicingCountry__c"] = address['Stato'];
        this.theCase["InvoicingProvince__c"] = address['Provincia'];
        this.theCase["InvoicingStreetNumberExtension__c"] =  address['Estens.Civico']? address['Estens.Civico'] : null;
        this.theCase["InvoicingStreetNumber__c"] = address['Civico'];
        this.theCase["InvoicingPlace__c"] = address['Localita']? address['Localita'] : null;
        this.theCase["InvoicingStreetCode__c"] = address['Codice Via Stradario SAP']? address['Codice Via Stradario SAP'] : null;
        this.theCase["InvoicingCityCode__c"] = address['Codice Comune SAP']? address['Codice Comune SAP'] : null;
    }

    handleNext(event){
        let validity = this.validate();
        if (validity.isValid) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        else {
            this.alert('Dati tabella', validity.errorMessage, 'error');
        }
    }

    handleCancell(event){
        console.log('******1');
        this.cancelCase = true;
        console.log('******2');
        /*const attributeChangeEvent = new FlowAttributeChangeEvent('cancelCase', this.cancelCase);
        this.dispatchEvent(attributeChangeEvent);*/
        /*const NavigationBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(NavigationBackEvent);*/
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    connectedCallback(){
        this.subscribeMC();
    }
}