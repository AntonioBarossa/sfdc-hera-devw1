import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";
import generatePicklistsData from "@salesforce/apex/HDT_LC_InterventionDependency.generatePicklistsData";

export default class HdtInterventionDependecy extends LightningElement {
    @api city = null;
    @api cityId = null;
    @api operationGroup = null;
    @api operationType = null;
    @api material = null;

    mapOfPicklistValues = {};
    eventButton;
    interviewId;

    operationGroups = [];
    operationTypes = [];
    materials = [];

    //subscribe
    @wire(MessageContext)
    messageContext;
    //subscribe

    get operationGroupDisabled() {
        return !this.city;
    }

    get operationTypeDisabled() {
        return !this.city || !this.operationGroup;
    }

    get materialsDisabled() {
        return !this.city || !this.operationGroup || !this.operationType;
    }

    connectedCallback() {
        this.subscription = subscribe(this.messageContext, BUTTONMC, (mc) => {
            if (this.interviewId == mc.sessionid) this.eventButton = mc.message;
        });

        if (!this.operationGroups.length && this.operationGroup) {
            this.operationGroups = [{ value: this.operationGroup, label: this.operationGroup }];
        }

        if (!this.operationTypes.length && this.operationType) {
            this.operationTypes = [{ value: this.operationType, label: this.operationType }];
        }

        if (!this.materials.length && this.material) {
            this.materials = [{ value: this.material, label: this.material }];
        }
    }

    handleCitySelected(event) {
        this.city = event.detail.code;

        if (this.city) {
            generatePicklistsData({ city: this.city })
                .then((result) => {
                    this.mapOfPicklistValues = result;
                    this.operationGroups = result.operationGroups;

                    if (this.operationGroup) {
                        this.operationTypes = this.mapOfPicklistValues.operationTypes[this.operationGroup];
                        if (this.operationType) {
                            this.materials = this.mapOfPicklistValues.materials[this.operationGroup + this.operationType];
                        }
                    } else {
                        this.operationGroup = null;
                        this.operationType = null;
                        this.material = null;
                    }
                })
                .catch((error) => {
                    this.city = null;

                    this.operationGroups = null;
                    this.operationTypes = null;
                    this.materials = null;
                    console.error(error);

                    let event = new ShowToastEvent({
                        title: "Attenzione!",
                        message: error.body.message,
                        variant: "warning",
                    });
                    this.dispatchEvent(event);
                });
        } else {
            this.operationGroup = null;
            this.operationType = null;
            this.material = null;

            this.operationGroups = null;
            this.operationTypes = null;
            this.materials = null;
        }
    }

    operationGroupChange(event) {
        if (this.operationGroup != event.detail.value) {
            this.operationGroup = event.detail.value;
            this.operationTypes = this.mapOfPicklistValues.operationTypes[this.operationGroup];

            this.operationType = null;
            this.material = null;
        }
    }

    operationTypeChange(event) {
        if (this.operationType != event.detail.value) {
            this.operationType = event.detail.value;
            this.materials = this.mapOfPicklistValues.materials[this.operationGroup + this.operationType];
            this.material = null;
        }
    }

    materialChange(event) {
        this.material = event.detail.value;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    @api
    validate() {
        this.unsubscribeToMessageChannel();
        let message;
        let isValid = true;

        if ("cancel" != this.eventButton && "draft" != this.eventButton) {
            if (!this.city) {
                this.template.querySelector('[data-id="city"]').reportValidity();
                isValid = false;
            }
            if (!this.operationGroup) {
                this.template.querySelector('[data-id="operationGroup"]').reportValidity();
                isValid = false;
            }
            if (!this.operationType) {
                this.template.querySelector('[data-id="operationType"]').reportValidity();
                isValid = false;
            }
            if (!this.material) {
                this.template.querySelector('[data-id="material"]').reportValidity();
                isValid = false;
            }
        }

        return {
            isValid: isValid,
            errorMessage: message ? message : null,
        };
    }
}
