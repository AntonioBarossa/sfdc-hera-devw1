import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getItems from '@salesforce/apex/HDT_LC_CampaignMemberAssigmentItem.getItemsByMemberAssignment';
import checkCommercialCodeUniqueness from '@salesforce/apex/HDT_LC_CampaignsController.checkCommercialCodeUniqueness';
import createCommercialCode from '@salesforce/apex/HDT_LC_CampaignsController.createCommercialCode';
import getUserRole from '@salesforce/apex/HDT_LC_CampaignsController.getUserRole';
import USER_ID from '@salesforce/user/Id';
export default class HdtCreateCampaign extends LightningElement {
    @api recordId;
    objectApiName = 'Campaign';
    @track reitekFieldRequired = false;
    @track startDateFieldRequired = false;
    @track easyRequired=false;
    @track targetingModeFieldRequired = false;
    @track campaignRecurringFields = true;
    @track campaignInboundFields = false;
    @track campaignOutboundFields = false;
    @track campaignBillingFields = false;
    @track paperCampaignFields = false;
    @track campaignCommercialCodeFields = false;
    @track selectedCodeManagementModel = '';
    @track selectedCodeGenerationRule = '';
    @track isTecnologyWebService = false;
    @track tipology = '';
    @track recurringCampaignFieldsRequired = false;
    @track campaignMemberAssignmentRequired = false;
    @track campaignMemberAssignmentTypeRequired = false;
    @track categoryFieldRequired = true;
    @track channelFieldRequired = true;
    @track processTypeFieldRequired = false;
    @track percentageAllocationSum = 0;
    @track statusField = '';
    @track channelValues;
    @track paperRecId;
    @track userRoleBackOffice = false;
    // campaign Commercial Code Fields
    @track codeGenerationRuleRequired = false;
    @track prefixCodeRequired = false;
    @track codeValidityEndDateRequired = false;
    @track maxNumberEECodeUseRequired = false;
    @track maxNumberGASCodeUseRequired = false;
    @track maxNumberVASCodeUseRequired = false;
    @track codeConventionQuantityRequired = false;

    @wire(getUserRole, {
        userId: USER_ID
    }) wireuser({ error, data }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            this.userRoleBackOffice = data === 'Back Office' ? true : false;
            console.log(JSON.stringify(data));
        }
    }

    handleFormLoad(event) {
        this.statusField = this.template.querySelector('.statusField > lightning-input-field').value;
    }

    renderedCallback() {
        if (this.template.querySelector('lightning-input-field.paperCampaignParameterField') != null) {
            this.paperRecId = this.template.querySelector('lightning-input-field.paperCampaignParameterField').value;
        }
    }

    handleChangeStatus(event) {

        let categoryField = this.template.querySelector('.categoryField > lightning-input-field') != null ? this.template.querySelector('.categoryField > lightning-input-field').value : '';
        let channelField = this.template.querySelector('.channelField > lightning-input-field') != null ? this.template.querySelector('.channelField > lightning-input-field').value : '';
        let recurringField = this.template.querySelector('.recurringField > lightning-input-field').value;
        this.statusField = event.detail.value;
        let processType = this.template.querySelector('.processType > lightning-input-field').value;

        if ( this.statusField!='Bozza' && channelField=='Telefonico Outbound' ) {
            this.easyRequired=true;
        }
        else{
            this.easyRequired=false;
        }
    
        if ("Campagna Contenitore" != categoryField && event.detail.value === 'Pianificata' && categoryField != null) {
            this.startDateFieldRequired = true;
            this.campaignInboundFields = (categoryField === 'Campagna CRM' && (processType == 'Entrambi' || processType == 'Nuovo Caso')) ? true : false;
            this.reitekFieldRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignOutboundFields = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentTypeRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignBillingFields = channelField.includes('Bolletta') ? true : false;
            this.paperCampaignFields = channelField.includes('Cartaceo') ? true : false;
            this.campaignCommercialCodeFields = (channelField.includes('Bolletta') || categoryField === 'Campagna Marketing Cloud' || categoryField === 'Campagna CRM') ? true : false;
            this.recurringCampaignFieldsRequired = recurringField;
        } else {  
            this.startDateFieldRequired = false;
            this.recurringCampaignFieldsRequired = false;
            this.reitekFieldRequired = false;
            this.campaignMemberAssignmentTypeRequired = false;
            this.campaignMemberAssignmentRequired = false;
            this.campaignCommercialCodeFields = false;
        }
    }

    handleChangeCategory(event) {
        this.channelFieldRequired = true;
        this.campaignCommercialCodeFields = (event.detail.value === 'Campagna Marketing Cloud' || event.detail.value === 'Campagna CRM') ? true : false;
        this.statusField = this.template.querySelector('.statusField > lightning-input-field').value;
        let categoryField = this.template.querySelector('.categoryField > lightning-input-field').value;
        let channelField = this.template.querySelector('.channelField > lightning-input-field') != null ? this.template.querySelector('.channelField > lightning-input-field').value : '';
        let recurringField = this.template.querySelector('.recurringField > lightning-input-field').value;
        let processType = this.template.querySelector('.processType > lightning-input-field').value;

        if ("Campagna Contenitore" != event.detail.value && this.statusField === 'Pianificata') {
            this.startDateFieldRequired = true;
            this.campaignInboundFields = (categoryField === 'Campagna CRM' && (processType == 'Entrambi' || processType == 'Nuovo Caso')) ? true : false;
            this.reitekFieldRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignOutboundFields = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentTypeRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignMemberAssignmentRequired = channelField.includes('Telefonico Outbound') ? true : false;
            this.campaignBillingFields = channelField.includes('Bolletta') ? true : false;
            this.recurringCampaignFieldsRequired = recurringField;
        } else {
            if ("Campagna Contenitore" == event.detail.value) {
                this.channelFieldRequired = false;
            }
            this.startDateFieldRequired = false;
            this.recurringCampaignFieldsRequired = false;
            this.reitekFieldRequired = false;
            this.campaignMemberAssignmentTypeRequired = false;
            this.campaignMemberAssignmentRequired = false;
        }
    }

    handleChangeProcessType(event){
        let processType = event.detail.value;
        let categoryField = this.template.querySelector('.categoryField > lightning-input-field') != null ? this.template.querySelector('.categoryField > lightning-input-field').value : '';
        this.campaignInboundFields = (categoryField === 'Campagna CRM' && (processType == 'Entrambi' || processType == 'Nuovo Caso')) ? true : false;
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
        if (this.template.querySelector('.categoryField > lightning-input-field').value != null) {
            this.campaignCommercialCodeFields = (event.detail.value === 'Bolletta' || this.template.querySelector('.categoryField > lightning-input-field').value === 'Campagna Marketing Cloud' || this.template.querySelector('.categoryField > lightning-input-field').value === 'Campagna CRM') ? true : false;
        }
        this.paperCampaignFields = event.detail.value.includes('Cartaceo') ? true : false;

        //reset fields

    }

    handleChangeCodeManagementModel(event) {
        this.selectedCodeManagementModel = event.detail.value;
        this.codeGenerationRuleRequired = (event.detail.value != '' && event.detail.value != 'Nessuno') ? true : false;
        if (!this.codeGenerationRuleRequired) {
            this.prefixCodeRequired = false;
            this.codeValidityEndDateRequired = false;
            this.maxNumberEECodeUseRequired = false;
            this.maxNumberGASCodeUseRequired = false;
            this.maxNumberVASCodeUseRequired = false;
            this.codeConventionQuantityRequired = false;
        }
    }

    handleChangeCodeGenerationRule(event) {
        this.selectedCodeGenerationRule = event.detail.value;
        this.prefixCodeRequired = event.detail.value != '' ? true : false;
        this.codeValidityEndDateRequired = event.detail.value != '' ? true : false;
        this.maxNumberEECodeUseRequired = event.detail.value != '' ? true : false;
        this.maxNumberGASCodeUseRequired = event.detail.value != '' ? true : false;
        this.maxNumberVASCodeUseRequired = event.detail.value != '' ? true : false;
        this.codeConventionQuantityRequired = event.detail.value != '' ? true : false;
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

    handleReitek(event) {
        this.isTecnologyWebService = ('Web Service' == event.detail.value ? true : false);
        console.log("CHECK Tecnology:" + this.isTecnologyWebService);
    }
    handleType(event) {
        this.tipology = event.detail.value;
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
        }
        else if (this.isTecnologyWebService && (this.tipology != 'Call Back - Energy' && this.tipology != 'Call Back - VAS' && this.tipology != 'Win back')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "",
                    message: `In Caso di Tecnologia integrazione Reitek "Web Service" la tipologia deve essere "CallBack" oppure "Winback"`,
                    variant: "error",
                    mode: "sticky"
                })
            );
        } else if (fields.RecurringCampaign__c && fields.ParentId != null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "",
                    message: "La campanga non puo avere un Parent ed essere ricorrente nello stesso tempo",
                    variant: "error"
                })
            );
        } else if (this.campaignCommercialCodeFields && fields.PrefixCode__c != null) {
            checkCommercialCodeUniqueness({ commercialCode: fields.PrefixCode__c, campaignId: this.recordId }).then(response => {
                console.log(JSON.stringify(response));
                if (response) {
                    console.log('unique');
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "",
                            message: "Codice gia utilizzato, sceglierne un altro",
                            variant: "error"
                        })
                    );
                }
            }).catch(err => {
                console.log(err);
            });
        }
        else {
            if (this.paperCampaignFields) {
                console.log(fields.Name);
                this.template.querySelector('c-hdt-paper-campaign-fields').handleSubmit(fields.Name);
            } else {
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }
    }

    handleRecordSubmitted(event) {
        //submit the form
        if (event.detail.newRecordId) {
            this.template.querySelector('lightning-input-field.paperCampaignParameterField').value = event.detail.newRecordId;
            this.template.querySelector('lightning-record-edit-form').submit();
        }
    }

    handleErrorOccurred(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Update failed!",
                message: event.detail.msg,
                variant: "error"
            })
        );
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
        if (this.selectedCodeGenerationRule == 'Manuale' && this.statusField == 'Pianificata') {
            console.log("yes");
            //create Commercial Code record
            createCommercialCode({ campaignId: this.recordId }).then(response => {
                console.log(JSON.stringify(response));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Codice commerciale creato con successo",
                        message: '',
                        variant: "success"
                    })
                );
            }).catch(err => {
                console.log(err);
            });
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: "Campagna Aggiornata",
                message: '',
                variant: "success"
            })
        );
    }
}