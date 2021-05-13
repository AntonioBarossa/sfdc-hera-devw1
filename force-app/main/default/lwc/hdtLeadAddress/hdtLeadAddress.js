import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAddressObject from '@salesforce/apex/HDT_UTL_Lead.getAddressObject'; 
import updateLead from '@salesforce/apex/HDT_UTL_Lead.updateLead'; 
export default class HdtLeadAddress extends LightningElement {

    @api recordId;
    @api vis = false;
    @track addressObject;
    @track flag = true;
    @api objectApiName;
    @track currentObjectName = 'Lead';
    @api leadAddress = [];
    fieldsToUpdate;
    isVerified= false;

    @wire(getAddressObject, {Id: '$recordId'})
    addressInfo({ error, data }) {
        if(data){
            this.addressObject= data;
            this.flag= true;
        }
        else if(error){
            console.log(error);
        }

    }
    renderedCallback(){
        this.currentObjectName = this.objectApiName;
        // if(this.flag){
        //     this.template.querySelector("c-hdt-target-object-address-fields").toObjectAddress();
        // }
    }

    handleSave(){
        //this.template.querySelector("c-hdt-target-object-address-fields").handleConfirm();
        this.leadAddress=this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
        console.log("PROVAPROVAPROVA_:" + JSON.stringify(this.leadAddress));
        this.updateLeadAdress();
        if(this.isVerified){
            if(this.fieldsToUpdate !=undefined){
                this.fieldsToUpdate['Id']= this.recordId;
                console.log(this.fieldsToUpdate);
                updateLead({
                    lead: this.fieldsToUpdate
                });
            }
        }else{
            const event = new ShowToastEvent({
                message: " L\'indirizzo non è stato verificato! ",
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        
    }

    updateLeadAdress(){

        if(this.leadAddress!= undefined){

            if(this.leadAddress['Via'] != null){
                this.fieldsToUpdate['Street'] = this.leadAddress['Via'];
            }
            if(this.leadAddress['Comune'] != null){
                this.fieldsToUpdate['City'] = this.leadAddress['Comune'];
            }
            if(this.leadAddress['CAP'] != null){
                this.fieldsToUpdate['PostalCode'] = this.leadAddress['CAP'];
            }
            if(this.leadAddress['Stato'] != null){
                this.fieldsToUpdate['Country'] = this.leadAddress['Stato'];
            }
            if(this.leadAddress['Provincia'] != null){
                this.fieldsToUpdate['State'] = this.leadAddress['Provincia'];
            }
            if(this.leadAddress['Codice Comune SAP'] != null){
                this.fieldsToUpdate['CityCode__c'] = this.leadAddress['Codice Comune SAP'];
            }
            if(this.leadAddress['Codice Via Stradario SAP'] != null){
                this.fieldsToUpdate['StreetCode__c'] = this.leadAddress['Codice Via Stradario SAP'];
            }
            if(this.leadAddress['Estens.Civico'] != null){
                this.fieldsToUpdate['StreetNumberExtension__c'] = this.leadAddress['Estens.Civico'];
            }
            if(this.leadAddress['Civico'] != null){
                this.fieldsToUpdate['StreetNumber__c'] = this.leadAddress['Civico'];
            }
            if(this.leadAddress['Flag Verificato'] !=null){
                this.isVerified = this.leadAddress['Flag Verificato'];
            }
        }
    }

}