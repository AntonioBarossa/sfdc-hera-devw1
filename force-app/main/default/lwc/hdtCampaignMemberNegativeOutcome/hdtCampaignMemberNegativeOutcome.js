import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCampaignMemberStatusValue from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMemberStatus';
import getNegativeOutcomeValues from '@salesforce/apex/HDT_LC_CampaignsController.getOutcomeValues';

export default class HdtCampaignMemberNegativeOutcome extends LightningElement {
    @track isModalOpen = false;
    @track value;
    @api campaignMemberId;

    options;

    // options = [
    //     { value: 'Black List', label: 'Black List' },
    //     { value: 'Già Cliente', label: 'Già Cliente' },
    //     { value: 'Da poco con altro Gestore', label: 'Da poco con altro Gestore' },
    //     { value: 'Cliente non coperto rete gas', label: 'Cliente non coperto rete gas' },
    //     { value: 'Non interessato all offerta', label: 'Non interessato all offerta' },
    //     { value: 'Prima attivazione', label: 'Prima attivazione' },
    //     { value: 'Script completato', label: 'Script completato' },
    //     { value: 'Riaggancia e rifiuta il contatto', label: 'Riaggancia e rifiuta il contatto' },
    //     { value: 'Fuori Target', label: 'Fuori Target' },
    //     { value: 'Titolare della fornitura non disponibile', label: 'Titolare della fornitura non disponibile' },
    //     { value: 'La proposta non è competitiva', label: 'La proposta non è competitiva' }
    // ];

    negativeResultClick() {
       
        getNegativeOutcomeValues({'campaignMemberId': this.campaignMemberId , 'outcomeType': 'Utile Negativo'}).then(result => {

            console.log('result --> '+JSON.stringify(result));
            var conts = result;
            for(var key in conts){
                console.log('conts[key] --> '+conts[key]);
                console.log('key --> '+key);
                const option = {
                    label: key,
                    value: conts[key]
                };

                if(this.options != undefined){
                    this.options = [...this.options, option];
                }
                else{
                    this.options = [option];
                }

            }

            console.log('this.options --> '+JSON.stringify(this.options));
        })
        .catch(error => {
            alert(JSON.stringify(error));
        });
    
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    submitDetails() {
        updateCampaignMemberStatusValue({ 'campaignMemberId': this.campaignMemberId, 'statusValue': this.value }).then(data => {
            console.log("ok" + JSON.stringify(data));
            this.isModalOpen = false;
            let status = this.value;
            this.dispatchEvent(new CustomEvent('aftersubmit', { detail: {status} }));
        }).catch(err => {
            console.log(err);
        });
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log(this.value);
    }

}