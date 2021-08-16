import { LightningElement ,track,wire,api} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import requiredCampaignCheck from '@salesforce/apex/HDT_LC_CampaignsController.requiredCampaignCheck';
import getAccount from '@salesforce/apex/HDT_LC_CampaignsController.getCurrentAccount';



export default class HdtConfirmationAccount extends LightningElement {
   currentPageReference = null; 
   urlStateParameters = null;
   
   /* Params from Url */
   @track c__varId = null;
   @track campaignMembers;
   @track noCampaignMembers
   @track yesCampaignMembers
   @track currentAccount;
   
   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      if (currentPageReference) {
         this.urlStateParameters = currentPageReference.state;
         this.setParametersBasedOnUrl();
      }
   }
   
   setParametersBasedOnUrl() {
      this.c__varId = this.urlStateParameters.c__varId || null;
      
   }
   @api
   getIdAccount(){
      return this.c__varId;
   }
   @api getYesCampaignMembers(){
      return this.yesCampaignMembers;
   }
   
   getRequiredCampaign(){
      requiredCampaignCheck({ id: this.c__varId} )
      .then(result => {
         console.log(JSON.stringify(result));
         this.campaignMembers=result;
         console.log(result.length);
         if (result.length===0) {
            console.log('Non ci sono campagne');
            this.noCampaignMembers=true;
            this.yesCampaignMembers=false
         }
         else{
            this.yesCampaignMembers=true;
            this.noCampaignMembers=false;

         }
         
      })
      .catch(error => {
         this.error = error;
      });
   }
   
   
   getCurrentAccount(){
      getAccount({ id: this.c__varId})
      .then(result => {
         console.log(JSON.stringify(result));
         this.currentAccount=result;
         console.log(result.length);
         
         
      })
      .catch(error => {
         this.error = error;
      });
   }
  
   
   connectedCallback(){
      console.log('connectedCallback id : '+this.c__varId);
      
      this.getRequiredCampaign();
      this. getCurrentAccount();
   }
   
   
   
}