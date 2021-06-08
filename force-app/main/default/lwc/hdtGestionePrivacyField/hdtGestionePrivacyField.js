import { LightningElement,track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import INDIVIDUAL_OBJECT from '@salesforce/schema/Individual';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import updateIndividual from '@salesforce/apex/HDT_LC_GestionePrivacyField.updateIndividual';

export default class HdtGestionePrivacyField extends NavigationMixin(LightningElement) {


    @api objectApiName;
    @api recordId;
    @wire(getObjectInfo, { objectApiName: INDIVIDUAL_OBJECT })
    individualInfo;
    
    @api areDetailsVisible = false;
    @api areProfilingVisible = false;
    @api areThirdPartsVisible = false;
    handleChange(event) {
        this.areDetailsVisible = event.target.checked;

    }

    handleProfilingChange(event) {
        this.areProfilingVisible= event.target.checked;

    }

    
    handleThirdPartsChange(event) {
        this.areThirdPartsVisible= event.target.checked;

    }


    handlesave(){
        console.log(this.objectApiName);
        console.log(this.recordId);
       

         let isValidated= true;

        let MarketingPrivacy =this.template.querySelector('[data-id="MarketingPrivacy"]').value;
        let PrivacyMarketingChoiceSource = this.template.querySelector('[data-id="PrivacyMarketingChoiceSource"]').value;
        let ProfilingPrivacy = this.template.querySelector('[data-id="ProfilingPrivacy"]').value;
        let PrivacyProfilingChoiceSource =this.template.querySelector('[data-id="PrivacyProfilingChoiceSource"]').value;
        let ProfilingCompanyConsent= this.template.querySelector('[data-id="ProfilingCompanyConsent"]').value;
        let PrivacyProfilingConsentInitiative= this.template.querySelector('[data-id="PrivacyProfilingConsentInitiative"]').value;
        let ThirdPartyPrivacy= this.template.querySelector('[data-id="ThirdPartyPrivacy"]').value;
        let PrivacyThirdPartyChoiceSource= this.template.querySelector('[data-id="PrivacyThirdPartyChoiceSource"]').value;
        let ThirdPartyCompanyConsent= this.template.querySelector('[data-id="ThirdPartyCompanyConsent"]').value;
        let PrivacyThirdPartyConsentInitiative= this.template.querySelector('[data-id="PrivacyThirdPartyConsentInitiative"]').value;
        let MarketingCompanyConsent= this.template.querySelector('[data-id="MarketingCompanyConsent"]').value;
        let PrivacyMarketingConsentInitiative= this.template.querySelector('[data-id="PrivacyMarketingConsentInitiative"]').value;

        if(!MarketingPrivacy.reportValidity()){
            isValidated=false;
        } 

        if(!PrivacyMarketingChoiceSource.reportValidity()){
            isValidated=false;
        } 

        if(!ProfilingPrivacy.reportValidity()){
            isValidated=false;
        } 

        if(!PrivacyProfilingChoiceSource .reportValidity()){
            isValidated=false;
        } 

        if(!ProfilingCompanyConsent .reportValidity()){
            isValidated=false;
        }

        if(!PrivacyProfilingConsentInitiative.reportValidity()){
            isValidated=false;
        }

        if(!ThirdPartyPrivacy.reportValidity()){
            isValidated=false;
        }

        if(!PrivacyThirdPartyChoiceSource.reportValidity()){
            isValidated=false;
        }

        if(!ThirdPartyCompanyConsent.reportValidity()){
            isValidated=false;
        }

        if(!PrivacyThirdPartyConsentInitiative.reportValidity()){
            isValidated=false;
        }

        if(!MarketingCompanyConsent.reportValidity()){
            isValidated=false;
        }

        if(!PrivacyMarketingConsentInitiative.reportValidity()){
            isValidated=false;
        }

        let indv= {
            "MarketingPrivacy": MarketingPrivacy.value,
            "PrivacyMarketingChoiceSource": PrivacyMarketingChoiceSource.value,
            "MarketingCompanyConsent": MarketingCompanyConsent.value,
            "PrivacyMarketingConsentInitiative": PrivacyMarketingConsentInitiative.value,
            "ProfilingPrivacy" : ProfilingPrivacy.value,
            "PrivacyProfilingChoiceSource": PrivacyProfilingChoiceSource.value,
            "ProfilingCompanyConsent": ProfilingCompanyConsent.value,
            "PrivacyProfilingConsentInitiative" : PrivacyProfilingConsentInitiative.value,
            "ThirdPartyPrivacy" : ThirdPartyPrivacy.value,
            "PrivacyThirdPartyChoiceSource" : PrivacyThirdPartyChoiceSource.value,
            "ThirdPartyCompanyConsent" : ThirdPartyCompanyConsent.value,
            "PrivacyThirdPartyConsentInitiative" : PrivacyThirdPartyConsentInitiative.value
            
        };

        updateIndividual({recordId:this.recordId,
            type:this.objectApiName,
            indvData:indv
          }).then((response) => {

          });

          
        
    }

}