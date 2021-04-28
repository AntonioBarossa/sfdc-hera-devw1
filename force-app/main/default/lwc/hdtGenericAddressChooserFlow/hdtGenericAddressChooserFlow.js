import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ID_FIELD from '@salesforce/schema/Case.Id';
import InvoicingPostalCode from '@salesforce/schema/Case.InvoicingPostalCode__c';
import InvoicingStreetNumber from '@salesforce/schema/Case.InvoicingStreetNumber__c';
import InvoicingCityCode from '@salesforce/schema/Case.InvoicingCityCode__c';
import InvoicingStreetCode from '@salesforce/schema/Case.InvoicingStreetCode__c';
import InvoicingCity from '@salesforce/schema/Case.InvoicingCity__c';
import InvoicingStreetNumberExtension from '@salesforce/schema/Case.InvoicingStreetNumberExtension__c';
import IsInvoicingVerified from '@salesforce/schema/Case.IsInvoicingVerified__c';
import InvoicingPlace from '@salesforce/schema/Case.InvoicingPlace__c';
import InvoicingStreetName from '@salesforce/schema/Case.InvoicingStreetName__c';
import InvoicingCountry from '@salesforce/schema/Case.InvoicingCountry__c';
import InvoicingStreetToponym from '@salesforce/schema/Case.InvoicingStreetToponym__c';
import InvoicingProvince from '@salesforce/schema/Case.InvoicingProvince__c';
import AddressFormula from '@salesforce/schema/Case.AddressFormula__c';

import SupplyPostalCode from '@salesforce/schema/Case.SupplyPostalCode__c';
import SupplyStreetNumber from '@salesforce/schema/Case.SupplyStreetNumber__c';
import SupplyCityCode from '@salesforce/schema/Case.SupplyCityCode__c';
import SupplyStreetCode from '@salesforce/schema/Case.SupplyStreetCode__c';
import SupplyCity from '@salesforce/schema/Case.SupplyCity__c';
import SupplyStreetNumberExtension from '@salesforce/schema/Case.SupplyStreetNumberExtension__c';
import SupplyIsAddressVerified from '@salesforce/schema/Case.SupplyIsAddressVerified__c';
import SupplyPlace from '@salesforce/schema/Case.SupplyPlace__c';
import SupplyProvince from '@salesforce/schema/Case.SupplyProvince__c';
import SupplyCountry from '@salesforce/schema/Case.SupplyCountry__c';
import SupplyStreetToponym from '@salesforce/schema/Case.SupplyStreetToponym__c';
import SupplyStreetName from '@salesforce/schema/Case.SupplyStreetName__c';
import DeliveryAddress from '@salesforce/schema/Case.DeliveryAddress__c';


const FIELDS = ['Case.InvoicingPostalCode__c',
				'Case.InvoicingStreetNumber__c',
				'Case.InvoicingCityCode__c',
				'Case.InvoicingStreetCode__c',
				'Case.InvoicingCity__c',
				'Case.InvoicingStreetNumberExtension__c',
				'Case.IsInvoicingVerified__c',
				'Case.InvoicingPlace__c',
				'Case.InvoicingStreetName__c',
				'Case.InvoicingCountry__c',
				'Case.InvoicingStreetToponym__c',
                'Case.InvoicingProvince__c',
                'Case.DeliveryAddress__c',
				'Case.SupplyPostalCode__c',
				'Case.SupplyStreetNumber__c',
				'Case.SupplyCityCode__c',
				'Case.SupplyStreetCode__c',
				'Case.SupplyCity__c',
				'Case.SupplyStreetNumberExtension__c',
				'Case.SupplyIsAddressVerified__c',
				'Case.SupplyPlace__c',
				'Case.SupplyProvince__c',
				'Case.SupplyCountry__c',
				'Case.SupplyStreetToponym__c',
				'Case.SupplyStreetName__c',
                'Case.AddressFormula__c'];

const FIELDS2 = ['Case.InvoicingPostalCode__c',
				'Case.InvoicingStreetNumber__c'];
export default class HdtGenericAddressChooserFlow extends LightningElement {

    @api addressType;
    @api recordId;
    @api accountId;
    @api nextLabel;
    @api nextVariant;
    @api addressLabel;
    @track addressWrapper={};
    @track address;
    @track isModalOpen=false;
    @api availableActions = [];
    @api
    get inputAddressLabel(){
        if(this.addressLabel != null && this.addressLabel != "" && this.addressLabel != "undefined"){
            return this.addressLabel;
        }else{
            return 'Indirizzo di recapito';
        }
    }

    @api
    get variantButton(){
        if(this.nextVariant != null && this.nextVariant !="" && this.nextVariant != "unedfined")
            return this.nextVariant;
        else 
            return "brand"
    }

    @api
    get labelButton(){
        if(this.nextLabel != null && this.nextLabel!="" && this.nextLabel != "unedfined")
            return this.nextLabel;
        else 
            return "Conferma Pratica"
    }

    @api
    getAddressValue(){
        return this.address;
    }
    
    handleChangeAddress(event){
        this.isModalOpen = true;
    }
    handleCloseModal(event){
        var addressWrapper = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
        console.log(JSON.stringify(addressWrapper));
        if((addressWrapper['Flag Verificato']) && addressWrapper.Via != null && addressWrapper.Via != ""){
            console.log('New Address');
            this.handleNewAddress();
            this.isModalOpen = false;
        }else if(addressWrapper.Via == null || addressWrapper.Via==""){
            this.isModalOpen = false;
            console.log('No change');
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message:'Attenzione! Seleziona un indirizzo valido.',
                    variant: 'error',
                }),
            );
        }
        
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        wiredCase({ error, data }) {
            if (error) {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('data error ' +message);
            } else if (data) {
                console.log('data loaded');
                this.caseRecord = data;
                console.log(JSON.stringify(this.caseRecord.fields));
                var inputParams;
                console.log(this.addressType + ' ' + this.accountId );
                if(this.addressType.localeCompare('ServicePoint') == 0){
                    inputParams = {
                        Stato : this.caseRecord.fields.SupplyCountry__c.value,
                        Provincia : this.caseRecord.fields.SupplyProvince__c.value,
                        Via  : this.caseRecord.fields.SupplyStreetName__c.value,
                        CAP : this.caseRecord.fields.SupplyPostalCode__c.value,
                        Comune  : this.caseRecord.fields.SupplyCity__c.value,
                        Civico  : this.caseRecord.fields.SupplyStreetNumber.value,
                        CodiceComuneSAP  : this.caseRecord.fields.SupplyCityCode__c.value,
                        EstensCivico : this.caseRecord.fields.SupplyStreetNumberExtension__c.value,
                        CodiceViaStradarioSAP  : this.caseRecord.fields.SupplyStreetCode__c.value,
                        FlagForzato  : false,
                        FlagVerificato  : this.caseRecord.fields.SupplyIsAddressVerified__c.value
                    }
                    this.address = this.caseRecord.fields.AddressFormula__c.value;
                }else{
                    inputParams = {
                        Stato : this.caseRecord.fields.InvoicingCountry__c.value,
                        Provincia : this.caseRecord.fields.InvoicingProvince__c.value,
                        Via  : this.caseRecord.fields.InvoicingStreetName__c.value,
                        CAP : this.caseRecord.fields.InvoicingPostalCode__c.value,
                        Comune  : this.caseRecord.fields.InvoicingCity__c.value,
                        Civico  : this.caseRecord.fields.InvoicingStreetNumber__c.value,
                        CodiceComuneSAP  : this.caseRecord.fields.InvoicingCityCode__c.value,
                        EstensCivico : this.caseRecord.fields.InvoicingStreetNumberExtension__c.value,
                        CodiceViaStradarioSAP  : this.caseRecord.fields.InvoicingStreetCode__c.value,
                        FlagForzato  : false,
                        FlagVerificato  : this.caseRecord.fields.IsInvoicingVerified__c.value
                    }
                    this.address = this.caseRecord.fields.DeliveryAddress__c.value;
                }
                console.log(inputParams);
                this.addressWrapper = inputParams;
            }
        }
    handleGoNext(event){
        try{
            console.log(this.address);
            if(!this.address){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message:'Attenzione! Seleziona un indirizzo valido.',
                        variant: 'error',
                    }),
                );
            }else{
                if(this.availableActions.find(action => action === 'NEXT')){

                    const navigateNextEvent = new FlowNavigationNextEvent();
        
                    this.dispatchEvent(navigateNextEvent);
        
                } else {
        
                    const navigateFinish = new FlowNavigationFinishEvent();
        
                    this.dispatchEvent(navigateFinish);
                }
            }
        }catch(error){
            console.log(error);
        }
    }
    handleNewAddress() {
        try{
            this.addressWrapper = this.template.querySelector('c-hdt-target-object-address-fields').handleAddressFields();
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            var estensioneCivico = ((this.addressWrapper.EstensCivico)? this.addressWrapper.EstensCivico:'');
            this.address = this.addressWrapper.Via + ' ' + this.addressWrapper.Civico + ' ' + estensioneCivico + ', ' + this.addressWrapper.Comune + ' ' + this.addressWrapper.Provincia + ', ' + this.addressWrapper.CAP + ' ' +this.addressWrapper.Stato;
            if(this.addressType.localeCompare('ServicePoint') == 0){
                fields[SupplyPostalCode.fieldApiName] = this.addressWrapper.CAP;
                fields[SupplyStreetNumber.fieldApiName] = this.addressWrapper.Civico;
                fields[SupplyCityCode.fieldApiName] = this.addressWrapper.CodiceComuneSAP;
                fields[SupplyStreetCode.fieldApiName] = this.addressWrapper.CodiceViaStradarioSAP;
                fields[SupplyCity.fieldApiName] = this.addressWrapper.Comune;
                fields[SupplyStreetNumberExtension.fieldApiName] = this.addressWrapper.EstensCivico;
                fields[SupplyIsAddressVerified.fieldApiName] = this.addressWrapper['Flag Verificato'];
                //fields[SupplyPlace.fieldApiName] = this.addressWrapper.
                fields[SupplyProvince.fieldApiName] = this.addressWrapper.Provincia;
                fields[SupplyCountry.fieldApiName] = this.addressWrapper.Stato;
                //fields[SupplyStreetToponym.fieldApiName] = this.addressWrapper.
                fields[SupplyStreetName.fieldApiName] = this.addressWrapper.Via;
                fields[AddressFormula.fieldApiName] = this.address;
            }else{
                fields[InvoicingPostalCode.fieldApiName] = this.addressWrapper.CAP;
                fields[InvoicingStreetNumber.fieldApiName] = this.addressWrapper.Civico;
                fields[InvoicingCityCode.fieldApiName] = this.addressWrapper.CodiceComuneSAP;
                fields[InvoicingStreetCode.fieldApiName] = this.addressWrapper.CodiceViaStradarioSAP;
                fields[InvoicingCity.fieldApiName] = this.addressWrapper.Comune;
                fields[InvoicingStreetNumberExtension.fieldApiName] = this.addressWrapper.EstensCivico;
                fields[IsInvoicingVerified.fieldApiName] = this.addressWrapper['Flag Verificato'];
                //fields[InvoicingPlace.fieldApiName] = this.addressWrapper.
                fields[InvoicingProvince.fieldApiName] = this.addressWrapper.Provincia;
                fields[InvoicingCountry.fieldApiName] = this.addressWrapper.Stato;
                //fields[InvoicingStreetToponym.fieldApiName] = this.addressWrapper.
                fields[InvoicingStreetName.fieldApiName] = this.addressWrapper.Via;
                fields[DeliveryAddress.fieldApiName] = this.address;
            }
            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    // Display fresh data in the form
                    console.log('Record aggiornato');
                })
                .catch(error => {
                    console.log('Errore in aggiornamento ' + error.body.message);
                });
        }catch(error){
            console.error(error);
        }
    }
}