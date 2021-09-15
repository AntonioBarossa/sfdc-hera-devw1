import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getSurveyCRM from '@salesforce/apex/HDT_LC_CampaignSurvey.getSurvey';
import saveSurveyResponse from '@salesforce/apex/HDT_LC_CampaignSurvey.saveSurveyResponse';
import getCampaignIdAndContactIdByMember from '@salesforce/apex/HDT_LC_CampaignsController.getAccountAndCampaign';
import updateCampaignMemberSurveyResponse from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMemberSurveyResponse';

export default class HdtCampaignSurvey extends NavigationMixin(LightningElement) {
  @api recordId;
  @api objectApiName;
  @track fieldValues;
  @track surveys = [];
  @track surveyCRM;
  @track picklistData = [];
  @track surveyId = [];
  @track errorMessage;
  @track isCampaignMember = false;
  @track showModal = false;
  @track campaignId;
  @track contactId;
  @track results;
  connectedCallback() {
    this.imgShow();//HRAWRM-544 10-09-2021
    if (this.objectApiName == "campaignmember") {
      this.isCampaignMember = true;
    }
    console.log('********Record::' +  this.objectApiName);
    console.log('********type::' +  this.recordId);
    getSurveyCRM({  objectApiName: this.objectApiName, recordId: this.recordId}).then(data => {
      if (data) {
        console.log('*****Length2:' + data);
        let ress = JSON.stringify(data);
        let surveyQuestions = [];
        this.fieldValues = data;
        let isPicklist = true;
        let isNumber = false;
        let isDate = false;
        console.log('*****Length:' + JSON.stringify(ress));
        if (data != null) {
          let ob = ress[0];
          //for (var j = 0; j < ress.length; j++) {
            surveyQuestions = [];
            for (var i = 1; i <= 20; i++) {
              if (data['Question' + i + '__c'] != null) {
                console.log("TRYTEST:");
                if (data['TypeResponse' + i + '__c'] == 'Si/No' || data['TypeResponse' + i + '__c'] == 'Indicatore 1-5') {
                  if(data['TypeResponse' + i + '__c'] == 'Si/No'){
                      isPicklist = true;
                      isDate = false;
                      this.picklistData = [{ label: 'Si', value:'Si'  },
                                           { label: 'No', value:'No'}];
                    }
                    else{
                      isPicklist = true;
                      isDate = false;
                      this.picklistData = [{ label: '1', value:'1'  },
                                        { label: '2', value:'2'},
                                        { label: '3', value:'3'},
                                        { label: '4', value:'4'},
                                        { label: '5', value:'5'}];
                    }
                } else if (data['TypeResponse' + i + '__c'] == 'Numerico') {
                  isPicklist = false;
                  isNumber = true;
                  isDate = false;
                } else if (data['TypeResponse' + i + '__c'] == 'Data') {
                  isPicklist = false;
                  isNumber = false;
                  isDate = true;
                } else {
                  isPicklist = false;
                  isNumber = false;
                  isDate = false;
                }
                surveyQuestions.push({
                  'question': data['Question' + i + '__c'], 'isPicklist': isPicklist, 'picklistData': this.picklistData,
                  'response': 'survey' + 0 + 'response' + i, 'isNumber': isNumber, 'isDate': isDate
                });
               //
                this.surveyId['survey' + 0] = data.Id;
               // this.surveyCRM = { "surveyQuestions": surveyQuestions, "id": 0 };
              //  this.surveys.push({ "surveyQuestions": surveyQuestions, "id": 0 });
              }
            }
            console.log("ECCOLO2:" + surveyQuestions);
            this.surveyCRM = { "surveyQuestions": surveyQuestions, "id": 0 };
            this.surveys.push({ "surveyQuestions": surveyQuestions, "id": 0 });
          //}
          console.log("ECCOLO:" + JSON.stringify(this.surveys));
          this.imgShow();//HRAWRM-544 10-09-2021
         // this.showModal = !this.isCampaignMember;
        }
      } else if (error) {
        console.log("try:" + error);
        this.showError(error);
        this.fieldValues = [];
        const event = new ShowToastEvent({
          message: this.errorMessage,
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
      }
    });

  }
  imgShow(){
     //Start  HRAWRM-544 10-09-2021
     console.log('surveySize: '+this.surveys.length);
     const selectedEvent = new CustomEvent("surveysize", {
     detail: this.surveys.length});
     this.dispatchEvent(selectedEvent);
     //End  HRAWRM-544 10-09-2021
  }
  @wire(getCampaignIdAndContactIdByMember, { campaignMemberId: '$recordId' }) campaign({ error, data }) {
    if (data) {
      this.campaignId = data.CampaignId;
      this.contactId = data.ContactId;
    }
  }

 /* @wire(getSurveyCRM, { objectApiName: '$objectApiName', recordId: '$recordId' })
  surveyInfo({ error, data }) {
    if (data) {
      let surveyQuestions = [];
      this.fieldValues = data;
      let isPicklist = true;
      let isNumber = false;
      let isDate = false;
      if (data.length > 0) {
        for (var j = 0; j < data.length; j++) {
          surveyQuestions = [];
          for (var i = 1; i <= 20; i++) {
            if (data[j].hasOwnProperty('Question' + i + '__c')) {
              if (data[j]['TypeResponse' + i + '__c'] == 'Si/No' || data[j]['TypeResponse' + i + '__c'] == 'Indicatore 1-5') {
                isPicklist = true;
                isDate = false;
                this.picklistData = this.getpicklistData(data[j]['ResponseValueList' + i + '__c']);
              } else if (data[j]['TypeResponse' + i + '__c'] == 'Numerico') {
                isPicklist = false;
                isNumber = true;
                isDate = false;
              } else if (data[j]['TypeResponse' + i + '__c'] == 'Data') {
                isPicklist = false;
                isNumber = false;
                isDate = true;
              } else {
                isPicklist = false;
                isNumber = false;
                isDate = false;
              }
              surveyQuestions.push({
                'question': data[j]['Question' + i + '__c'], 'isPicklist': isPicklist, 'picklistData': this.picklistData,
                'response': 'survey' + j + 'response' + i, 'isNumber': isNumber, 'isDate': isDate
              });
              this.surveyId['survey' + j] = data[j].Id;
            }
          }
          this.surveyCRM = { "surveyQuestions": surveyQuestions, "id": j };
          this.surveys.push({ "surveyQuestions": surveyQuestions, "id": j });
        }
        this.showModal = !this.isCampaignMember;
      }
    } else if (error) {
      console.log("try:" + error);
      this.showError(error);
      this.fieldValues = [];
      const event = new ShowToastEvent({
        message: this.errorMessage,
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
  };
*/
  handleSave(event) {
    //check validity of the input fields
    const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
      .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
    if (allValid) {
      var index = event.currentTarget.dataset.id;
      var responseData = {};
      for (var i = 1; i < 20; i++) {
        var response = this.template.querySelector('[data-id="survey' + index + 'response' + i + '"]');
        if (response != undefined && response != null) {
          console.log(response.value);
          responseData['Response' + i + '__c'] = response.value;
        }
      }
      responseData['Campaign__c'] = this.campaignId;
      responseData['Contact__c'] = this.contactId;
      responseData.SurveyCRM__c = this.surveyId['survey' + index];
      console.log(responseData);
      saveSurveyResponse({
        responses: responseData,
        campaignId: 'test'
      }).then((response) => {
        console.log(response);
        //update CampaignMemberSurveyResponse
        updateCampaignMemberSurveyResponse({ campaignMemberId: this.recordId, surveyResponseId: response.Id }).then(data => {
          console.log("ok" + JSON.stringify(data));
          //close the modal
          this.showModal = false; //HRAWRM-544 extra Bolzon
          const event = new ShowToastEvent({
            message: 'Survey salvata con successo!',
            variant: 'success',
            mode: 'dismissable'
          });
          this.dispatchEvent(event);
          //navigate to new created SurveyResponse
          // this[NavigationMixin.Navigate]({
          //   type: 'standard__recordPage',
          //   attributes: {
          //     recordId: response.Id,
          //     objectApiName: 'SurveyResponse__c',
          //     actionName: 'view'
          //   },
          // });//HRAWRM-544 extra
        }).catch(err => {
          console.log(err.body.message);
        });
      });
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: '',
          message: 'Si prega di compilare tutti i campi obbligatori',
          variant: "error"
        })
      );
    }
  }

  @api openModal() {
    if (this.surveys.length > 0) {
      this.showModal = true;
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: '',
          message: 'Non è disponibile una survey per questa campagna',
          variant: "error"
        })
      );
    }
  }
  
  closeModal() {
    this.showModal = false;
  }

  getpicklistData(options) {
    this.picklistData = [];
    let arrOptions = [];
    //if (options.length > 0) {
      arrOptions = options.split(',');
      arrOptions.forEach(element => {
        this.picklistData.push({ label: element, value: element });
      });
   // }
    return this.picklistData;
  }

  showError(error) {
    this.errorMessage = '';
    if (error.body.message) {
      this.errorMessage = this.errorMessage + ' ' + error.body.message;
    } else if (error.body.pageErrors) {
      if (error.body.pageErrors.length > 0) {
        for (var i = 0; i < error.body.pageErrors.length; i++) {
          this.errorMessage = this.errorMessage + ' ' + error.body.pageErrors[i].message;
        }
      }
    }

  }
}