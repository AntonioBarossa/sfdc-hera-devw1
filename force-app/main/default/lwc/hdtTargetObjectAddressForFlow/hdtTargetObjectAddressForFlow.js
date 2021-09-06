import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';


export default class HdtTargetObjectAddressForFlow extends LightningElement {

    theRecord;
    @api cancelCase;
    isValidFields;
    @api theCase;
    


    alert(title,msg,variant){
        const event = ShowToastEvent({
            title: title,
            message:  msg,
            variant: variant
        });
        dispatchEvent(event);
    }

    validFields() {
        console.log('validFields START');
        let isValid = true;
        this.isValidFields = true;
        let concatBillingErrorFields = '';
        let concatAddressErrorFields = '';


        //Validate address
        if(!this.theRecord['Indirizzo Estero']){
            console.log('entra in if ind estero');
            if (!this.theRecord['Flag Verificato']) {
                console.log('entra in flag verificato false ');
                isValid = false;
                this.isValidFields = false;
               // this.saveErrorMessage.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
                this.alert('Dati tabella','E\' necessario verificare l\'indirizzo per poter procedere al salvataggio','error')

            }
        } else {
            console.log('entra in else ind estero ');

            let foreignAddressMsg = 'Per poter salvare popolare i seguenti campi di indirizzo: ';
            if (this.theRecord['Stato'] === undefined || this.theRecord['Stato'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Stato, ');
            }
            if (this.theRecord['Provincia'] === undefined || this.theRecord['Provincia'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Provincia, ');
            }
            if (this.theRecord['Comune'] === undefined || this.theRecord['Comune'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Comune, ');
            }
            if (this.theRecord['Via'] === undefined || this.theRecord['Via'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Via, ');
            }
            if (this.theRecord['Civico'] === undefined || this.theRecord['Civico'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Civico, ');
            }
            if (this.theRecord['CAP'] === undefined || this.theRecord['CAP'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('CAP, ');
            }
            if (this.theRecord['CAP'] === undefined || this.theRecord['CAP'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('CAP, ');
            }
            if (concatAddressErrorFields !== '') {
                isValid = false;
                this.isValidFields = false;
                //this.saveErrorMessage.push('Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2));
                this.alert('Dati tabella','Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2),'error')
            }
        }        
        console.log('validFields END');

        return isValid;
    }

    
    validate(){
        console.log('save');

        this.theRecord = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        console.log('this.theRecord'+JSON.stringify(this.theRecord));
        
        if(this.theRecord['Stato']=='Italy'||this.theRecord['Stato']=='Italia'){
            this.theRecord['Stato']=='ITALIA';
        }

        this.validFields();
        if(this.isValidFields == true){
            return true;
        }else{
            return false; 
        }
    }

    populateCase(){
        this.theCase={...this.theCase};
        this.theCase["InvoicingStreetName__c"] = this.theRecord['Via'];
        this.theCase["InvoicingCity__c"] = this.theRecord['Comune'];
        this.theCase["InvoicingPostalCode__c"] = this.theRecord['CAP'];
        this.theCase["InvoicingCountry__c"] = this.theRecord['Stato'];
        this.theCase["InvoicingProvince__c"] = this.theRecord['Provincia'];
        this.theCase["InvoicingStreetNumberExtension__c"] =  this.theRecord['Estens.Civico'];
        this.theCase["InvoicingStreetNumber__c"] = this.theRecord['Civico'];
        this.theCase["InvoicingPlace__c"] = this.theRecord['Localita'];
    }

    handleNext(event){
        if(this.validate()){
            this.populateCase();
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
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