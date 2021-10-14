import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';


export default class HdtTargetObjectAddressForFlow extends LightningElement {

    @api cancelCase;
    @api theCase;
    
    @api hideNavigationButtons = false;

    @api
    validate() {
        let address = this.getAddress();
        let validity = this.validateAddress(address);
        if (validity.isValid) {
            this.populateCase(address);
        }
        return validity;
    }

    alert(title,msg,variant){
        console.log("alert: "+msg);
        const event = ShowToastEvent({
            title: title,
            message:  msg,
            variant: variant
        });
        dispatchEvent(event);
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
        } else {
            console.log('entra in else ind estero ');

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

    getAddress() {
        let address = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        if (address['Stato']=='Italy' || address['Stato']=='Italia'){
            address['Stato']=='ITALIA';
        }
        return address;
    }

    populateCase(address){
        this.theCase={...this.theCase};
        this.theCase["InvoicingStreetName__c"] = address['Via'];
        this.theCase["InvoicingCity__c"] = address['Comune'];
        this.theCase["InvoicingPostalCode__c"] = address['CAP'];
        this.theCase["InvoicingCountry__c"] = address['Stato'];
        this.theCase["InvoicingProvince__c"] = address['Provincia'];
        this.theCase["InvoicingStreetNumberExtension__c"] =  address['Estens.Civico'];
        this.theCase["InvoicingStreetNumber__c"] = address['Civico'];
        this.theCase["InvoicingPlace__c"] = address['Localita'];
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
}