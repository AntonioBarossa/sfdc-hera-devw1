import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getItems from '@salesforce/apex/HDT_LC_CampaignMemberAssigmentItem.getItemsByMemberAssignment';

export default class HdtCreateCampaign extends LightningElement {
    @api recordId;
    objectApiName = 'Campaign';
    @track reitekFieldRequired = false;
    @track startDateFieldRequired = false;
    @track targetingModeFieldRequired = false;
    @track campaignRecurringFields = true;
    @track campaignInboundFields = false;
    @track campaignOutboundFields = false;
    @track campaignBillingFields = false;
    @track recurringCampaignFieldsRequired = false;
    @track campaignMemberAssignmentRequired = false;
    @track campaignMemberAssignmentTypeRequired = false;
    @track categoryFieldRequired = true;
    @track channelFieldRequired = true;
    @track processTypeFieldRequired = false;
    @track percentageAllocationSum = 0;
    @track statusField = '';
    @track channelValues;

    handleFormLoad(event) {
        this.statusField = this.template.querySelector('.statusField > lightning-input-field').value;
    }

    handleChangeStatus(event) {

        let categoryField = this.template.querySelector('.categoryField > lightning-input-field') != null ? this.template.querySelector('.categoryField > lightning-input-field').value : '';
        let channelField = this.template.querySelector('.channelField > lightning-input-field') != null ? this.template.querySelector('.channelField > lightning-input-field').value : '';
        let recurringField = this.template.querySelector('.recurringField > lightning-input-field').value;
        this.statusField = event.detail.value;
        if ("Campagna Contenitore" != categoryField && event.detail.value === 'Pianificata') {
            this.startDateFieldRequired = true;
            this.campaignInboundFields = categoryField === 'Campagna CRM' ? true : false;
            this.reitekFieldRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignOutboundFields = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentTypeRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignBillingFields = channelField.includes('Bolletta') ? true : false;
            this.recurringCampaignFieldsRequired = recurringField;
        } else {
            this.startDateFieldRequired = false;
            this.recurringCampaignFieldsRequired = false;
            this.reitekFieldRequired = false;
            this.campaignMemberAssignmentTypeRequired = false;
            this.campaignMemberAssignmentRequired = false;
        }
    }

    handleChangeCategory(event) {
       // this.campaignInboundFields = event.detail.value === 'Campagna CRM' ? true : false;ù
        this.statusField = this.template.querySelector('.statusField > lightning-input-field').value;  
        let categoryField = this.template.querySelector('.categoryField > lightning-input-field').value;
        let channelField = this.template.querySelector('.channelField > lightning-input-field') != null ? this.template.querySelector('.channelField > lightning-input-field').value : '';
        let recurringField = this.template.querySelector('.recurringField > lightning-input-field').value;
       // this.statusField = event.detail.value;
        if ("Campagna Contenitore" != event.detail.value && this.statusField === 'Pianificata') {
            this.startDateFieldRequired = true;
            this.campaignInboundFields = categoryField === 'Campagna CRM' ? true : false;
            this.reitekFieldRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignOutboundFields = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentTypeRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignBillingFields = channelField.includes('Bolletta') ? true : false;
            this.recurringCampaignFieldsRequired = recurringField;
        } else {
            this.startDateFieldRequired = false;
            this.recurringCampaignFieldsRequired = false;
            this.reitekFieldRequired = false;
            this.campaignMemberAssignmentTypeRequired = false;
            this.campaignMemberAssignmentRequired = false;
        }
    }

    handleChangeChannel(event) {
        if (this.template.querySelector('.categoryField > lightning-input-field').value == 'Campagna Outbound' && event.detail.value.includes(';')) {
            let selectedValues = event.detail.value.split(";")
            let lastSelected = selectedValues[selectedValues.length - 1];
            this.channelValues = lastSelected;
        }
        this.reitekFieldRequired = (event.detail.value.includes('Telefonico Outbound') && this.statusField !== 'Bozza') ? true : false;
        this.campaignOutboundFields = event.detail.value.includes('Telefonico Outbound') ? true : false;
        this.campaignMemberAssignmentTypeRequired = (event.detail.value.includes('Telefonico Outbound') && this.statusField !== 'Bozza') ? true : false;
        this.campaignBillingFields = event.detail.value === 'Bolletta' ? true : false;

        //reset fields

    }

    handleRecurringCampaignChange(event) {
        this.recurringCampaignFieldsRequired = (event.detail.checked === true && this.statusField !== 'Bozza') ? true : false;
    }

    handleChangeAssignmentTye(event) {
        this.campaignMemberAssignmentRequired = (event.detail.value === 'Peso Percentuale' && this.statusField !== 'Bozza') ? true : false;
    }

    handleGenerationPeriodChange(event) {
        let value = event.detail.value;
        let endDate;
        if (value > 0) {
            let startDate = this.template.querySelector('.startDate > lightning-input-field').value;
            const date = new Date(startDate);
            date.setDate(date.getDate() + 7 * value);
            endDate = date.toISOString().slice(0, 10);
            this.template.querySelector('.endDate > lightning-input-field').value = endDate;
        }
    }

    handleChangeCampaignMemberAssignment(event) {
        let selectedMemberAssignmentId = event.detail.value[0];

        if (selectedMemberAssignmentId) {
            getItems({ Id: selectedMemberAssignmentId }).then(data => {
                //console.log("ok " + JSON.stringify(data));
                //check the PercentageAllocation__c sum of all items
                this.percentageAllocationSum = 0;
                data.forEach(item => {
                    this.percentageAllocationSum += item.PercentageAllocation__c;
                });
                console.log(this.percentageAllocationSum);
                //check the sum of PercentageAllocation__c
                if (this.percentageAllocationSum !== 100) {
                    let toastMsg;
                    toastMsg = this.dispatchEvent(
                        new ShowToastEvent({
                            title: "",
                            message: `Peso Percentuale di questa assegnazione è ${this.percentageAllocationSum}%`,
                            variant: "error",
                            mode: "sticky"
                        })
                    );
                }
            }).catch(err => {
                console.log(err);
            });
        } else {
            this.percentageAllocationSum = 0;
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        if (this.campaignMemberAssignmentRequired === true && this.campaignMemberAssignmentTypeRequired && this.percentageAllocationSum != 100) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "",
                    message: `Peso Percentuale di questa assegnazione è ${this.percentageAllocationSum}%`,
                    variant: "error",
                    mode: "sticky"
                })
            );
        } else {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Aggiornamento Fallito",
                message: event.detail.message,
                variant: "error"
            })
        );
    }

    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Campagna Aggiornata",
                message: '',
                variant: "success"
            })
        );
    }
}