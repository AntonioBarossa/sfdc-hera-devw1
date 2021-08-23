import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COMPANY_OWNER from '@salesforce/schema/Campaign.CompanyOwner__c';
import checkRole from '@salesforce/apex/HDT_UTL_Utils.getCurrentUserRole';

export default class HdtCampaignNewOverride extends LightningElement {
    @api objectApiName = 'Campaign';

    companyOwnerPicklist = [];
    disableCompanyOwner = true;
    companyDefault = '';

    @api handleSubmit() {
        
        if( this.template.querySelector('[data-id="companyOwner"]').value == '' ) {

            this.template.querySelector('[data-id="companyOwner"]').reportValidity();

        } else {
            this.template.querySelector('lightning-record-edit-form').submit();
        }
        
    }

    /** The recordtype id is the system default for the Master RecordType */
    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA' ,fieldApiName: COMPANY_OWNER })
    wiredPicklist({error,data}){
        if(data){

            console.log(data.values);

            this.companyOwnerPicklist = data.values;

        } else if(error){

            console.log(error)

        }

    }

    handleSuccess(event) {
        console.log(event.detail.id);
        let newRecordId = event.detail.id;
        this.dispatchEvent(new CustomEvent('afterExecution', { detail: {newRecordId} }));
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Campagna Salvata',
                message: '',
                variant: 'success'
            })
        );
    }

    connectedCallback() {

        checkRole({}).then((response) => {
            if(response == 'HDT_BackOffice'){
                this.disableCompanyOwner = false;
            }else if(response == 'HDT_FrontOffice_HERACOMM'){
                this.companyDefault = 'HERA COMM';                
                this.disableCompanyOwner = true;                
            }else if(response == 'HDT_FrontOffice_Reseller'){
                this.companyDefault = 'Reseller';
                this.disableCompanyOwner = true;                
            }
            else if(response == 'HDT_FrontOffice_MMS'){
                this.companyDefault = 'MMS';
                this.disableCompanyOwner = true;
            }
            else if(response == 'HDT_FrontOffice_AAAEBT'){
                this.companyDefault = 'AAA-EBT';
                this.disableCompanyOwner = true;
            }
            else{
                this.companyDefault = 'HERA COMM';
                this.disableCompanyOwner = true;
            }
        });

    }

    handleCompanyOwnerChange(event) {

        this.template.querySelector('[data-id="companyOwnerForm"]').value = event.target.value;
        console.log('nuovo valore ' + this.template.querySelector('[data-id="companyOwnerForm"]').value);

    }

}