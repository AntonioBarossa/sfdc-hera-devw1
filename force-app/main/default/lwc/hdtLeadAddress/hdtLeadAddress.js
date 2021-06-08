import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAddressObject from '@salesforce/apex/HDT_UTL_Lead.getAddressObject'; 
import updateLead2 from '@salesforce/apex/HDT_UTL_Lead.updateLeadAddress'; 
export default class HdtLeadAddress extends LightningElement {

    @api recordId;
    @api vis = false;
    @api addressObject;
    flag = true;
    @api objectApiName;
    @track currentObjectName = 'Lead';
    @api leadAddress = [];
    @api fieldsToUpdate = []; 
    isVerified= false;

   /*@wire(getAddressObject, {Id: '$recordId'})
    addressInfo({ error, data }) {
        if(data){
            console.log('******:'+ data);
            this.addressObject= data;
            this.flag= true;
        }
        else if(error){
            console.log(error);
        }

    }*/
    connectedCallback(){
        this.currentObjectName = this.objectApiName;
        console.log('******PROVA3:' + JSON.stringify(this.recordId));
        getAddressObject({id: this.recordId}).then((response) => { 
            console.log('******PROVA2:'+ JSON.stringify(response));
            this.addressObject = response;
            this.template.querySelector("c-hdt-target-object-address-fields").handleAddressValues(response);
        });
        // if(this.flag){
        //     this.template.querySelector("c-hdt-target-object-address-fields").toObjectAddress();
        // }
    }

    handleSave(){
        //this.template.querySelector("c-hdt-target-object-address-fields").handleConfirm();
        this.leadAddress=this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
        console.log("PROVAPROVAPROVA_:" + JSON.stringify(this.leadAddress));
        this.updateLeadAdress();
        console.log("DENTROUPDATELEADADDRES6");
        if(this.isVerified){
            console.log("DENTROUPDATELEADADDRES7");
            if(this.fieldsToUpdate !=undefined){
                console.log("DENTROUPDATELEADADDRES8");
                this.fieldsToUpdate['Id']= this.recordId;
                console.log("DENTROUPDATELEADADDRES9");
                console.log(this.fieldsToUpdate);
                updateLead2({
                    recordid : this.recordId,
                    lead: this.leadAddress
                }).then((response) => {
                    const event = new ShowToastEvent({
                        message: "Successo",
                        variant: 'Successo',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
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
            console.log("DENTROUPDATELEADADDRESS");
            if(this.leadAddress['Via'] != null){
                this.fieldsToUpdate['Street'] = this.leadAddress['Via'] + ' ' + this.leadAddress['Civico'];
                this.fieldsToUpdate['StreetName__c'] = this.leadAddress['Via'];
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
            console.log("DENTROUPDATELEADADDRESS3");
            if(this.leadAddress['Flag Verificato'] !=null){
                console.log("DENTROUPDATELEADADDRESS2");
                this.isVerified = this.leadAddress['Flag Verificato'];
            }
        }
    }

}