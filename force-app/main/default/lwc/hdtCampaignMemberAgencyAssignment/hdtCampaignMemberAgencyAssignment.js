import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import CHANNEL_FIELD from '@salesforce/schema/Campaign.Channel__c';
import getUnassignedCampaignMembers from '@salesforce/apex/HDT_LC_CampaignsController.getUnassignedCampaignMembers';
import getAccountsforCampaignMembers from '@salesforce/apex/HDT_LC_CampaignsController.getAccountsforCampaignMembers';

export default class HdtCampaignMemberAgencyAssignment extends LightningElement {
    @api recordId;
    @track isOutbound = false;
    @track assignmentType = 'Percentuale';
    @track inputFormatStyle = 'percent-fixed';
    @track maxValue;
    @track showResults = true;
    @track membersList = [];
    @track totalResults;
    @track remainingToAssign;
    @track rangeOverflowMessage;

    get options() {
        return [
            { label: 'Percentuale', value: 'Percentuale' },
            { label: 'Numerico', value: 'Numerico' },
        ];
    }

    @track agencies = [];

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [CHANNEL_FIELD]
    })
    campaign(result) {
        if (result.error) {
            console.log(error);
        } else if (result.data) {
            if (result.data.fields.Channel__c.value == "Telefonico Outbound") {

                getUnassignedCampaignMembers({ campaignId: this.recordId })
                    .then(result => {
                        console.log(JSON.stringify(result));
                        this.membersList = result.length > 0 ? result : [];
                        this.showResults = result.length > 0 ? true : false;
                        this.totalResults = result.length > 0 ? result.length : 0;
                        this.remainingToAssign = this.totalResults;
                        this.agencies.forEach(agency => {
                            agency.maxValue = this.assignmentType == 'Percentuale' ? 100 : this.totalResults;
                        });
                        this.rangeOverflowMessage = `Il valore massimo valido è ${this.maxValue}`;
                        if (this.totalResults == 0) {
                            let errmsg = "In Attesa del Targeting";
                            this.dispatchEvent(
                                new CustomEvent(
                                    'showError',
                                    {
                                        detail: { errmsg }
                                    }
                                )
                            );
                        } else {
                            this.isOutbound = true;
                        }
                    })
                    .catch(error => {
                        console.log(JSON.stringify(error));
                    });
            } else {
                let errmsg = "Non Abilitato per questo tipo di campagna";
                this.dispatchEvent(
                    new CustomEvent(
                        'showError',
                        {
                            detail: { errmsg }
                        }
                    )
                );
            }
        }
    }

    @wire(getAccountsforCampaignMembers)
    accounts(result) {
        if (result.error) {
            console.log(JSON.stringify(result.error));
        } else if (result.data) {
            console.log(JSON.stringify(result.data));
            result.data.forEach(item => {
                this.agencies.push({ name: item.Name, id: item.Id, maxValue: 0 })
            });
        }
    }

    handleAssignmentTypeChange(event) {
        this.assignmentType = event.detail.value;
        this.inputFormatStyle = this.assignmentType == 'Percentuale' ? 'percent-fixed' : 'decimal';
        let inputs = this.template.querySelectorAll('.inpValue > lightning-input');
        inputs.forEach(inp => {
            inp.value = '';
        });
        this.remainingToAssign = this.totalResults;
    }

    handleValueChange(event) {
        let currentValue = parseInt(event.detail.value);
        let currentElem = this.template.querySelector("[data-id='" + event.currentTarget.dataset.id + "']");
        let agency = this.agencies.find(ag => ag.id === event.currentTarget.dataset.id);
        let inputs = this.template.querySelectorAll('.inpValue > lightning-input');
        let assignedSoFar = 0;
        inputs.forEach(inp => {
            assignedSoFar += inp.value ? parseInt(inp.value) : 0;
        });

        //calculate max value allowed to insert
        if (this.assignmentType == 'Percentuale') {
            let assignedSoFarNum = Math.floor(assignedSoFar * this.totalResults / 100);
            this.remainingToAssign = this.totalResults - assignedSoFarNum < 0 ? this.totalResults - assignedSoFarNum + Math.floor(currentValue * this.totalResults / 100) : this.totalResults - assignedSoFarNum;
            agency.maxValue = 100 - assignedSoFar + currentValue;
        } else {
            this.remainingToAssign = this.totalResults - assignedSoFar < 0 ? this.totalResults - assignedSoFar + currentValue : this.totalResults - assignedSoFar;
            agency.maxValue = this.totalResults - assignedSoFar + currentValue;
        }

        //report validity of the current input value
        this.rangeOverflowMessage = `Il valore massimo valido è ${agency.maxValue}`;
        currentElem.reportValidity();

        //clear validity message from other agencies
        let otherAgencies = this.agencies.filter(ag => ag.id !== event.currentTarget.dataset.id);
        otherAgencies.forEach(agency => {
            agency.maxValue = this.assignmentType == 'Percentuale' ? 100 : this.totalResults;
            this.template.querySelector("[data-id='" + agency.id + "']").reportValidity();
        });
    }

    @api handleAssignAgency() {
        let assignedObj = [];
        let totalValues = 0;
        this.agencies.forEach(agency => {
            let val = this.template.querySelector("[data-id='" + agency.id + "']").value;
            val = this.assignmentType == 'Percentuale' && val > 0 ? Math.floor(val * this.totalResults / 100) : val;
            totalValues += val;
            if (val > 0) {
                assignedObj.push({id: agency.id, value: val});
            }
        });
        console.log(JSON.stringify(assignedObj));
        if (totalValues > 0 && totalValues <= this.totalResults) {
            //update the agencies
            console.log("submited");
        }
    }
}