import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewCase from '@salesforce/apex/HDT_LC_CampaignsController.getServiceCatalogUrlByCaseType';
import ObligatoryClientSurvey from '@salesforce/label/c.ObligatoryClientSurvey';
import getCampaignAndAccountByMember from '@salesforce/apex/HDT_LC_CampaignsController.getCampaignAndAccountByMember';
import getEcid from '@salesforce/apex/HDT_LC_CampaignsController.getEcid';
import isCommunity from '@salesforce/apex/HDT_LC_SellingWizardController.checkCommunityLogin';
import getCurrentProfile from '@salesforce/apex/HDT_LC_CampaignsController.getCurrentProfile';


export default class hdtCampaignMemberButtonList extends NavigationMixin(LightningElement) {
    @api recordId;
    caseObj = null;
    CampaignProcessType = '';
    processType = '';
    campaignMemberStatus = '';
    isCommunity;
    @track ecid;
    @track firstLoginTime;
    @track currentUserProfile;


    connectedCallback() {

        isCommunity().then(result => {
            this.isCommunity = result;
        }).catch(error => {
            console.error(error);
        });

        getCampaignAndAccountByMember({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            this.CampaignProcessType = data.Campaign.ProcessType__c;
            this.campaignMemberStatus = data.Campaign.PositiveOutcomeDefaultStatus__c;
            console.log('CampaignProcessType --> '+this.CampaignProcessType);
            this.caseObj = {
                'Subject': 'PostVendita',
                'AccountId': data?.Contact?.AccountId,
                'Cluster__c': data.Campaign.CaseCategory__c,
                'Type': data.Campaign.CaseSubCategory__c,
                'Campaign__c': data.CampaignId,
                'Lead__c' : data.LeadId
            };
            console.log(JSON.stringify(this.caseObj));
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.status}`,
                    message: `${error.body.message}`,
                    variant: "error"
                })
            );
        });

        getCurrentProfile({ 'campaignMemberId': this.recordId}).then(data => {
            this.currentUserProfile = data;
            
        }),error => {
            console.log('getCurrentProfile ERROR');
            console.log(error);
        };  
    }

    newCaseClick() {
        console.log('START newCaseClick');
        
        if(this.currentUserProfile === 'Hera Teleseller Partner User'){
            getEcid({ 'campaignMemberId': this.recordId}).then(data => {
                console.log("getEcid launch SUCCESS --> " + JSON.stringify(data));
                this.ecid = data;
                console.log('getEcid this.ecid --> '+this.ecid);
    
                if(this.ecid == ObligatoryClientSurvey){
                    console.log(this.ecid);
                    const evt = new ShowToastEvent({
                        title: 'Attenzione!',
                        message: ObligatoryClientSurvey,
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else if(this.ecid != null && this.ecid != undefined && this.ecid != ''){
    
                    console.log('newSaleClick PUNTO 1');
                    this.launchClickToCall();
                    console.log('newSaleClick PUNTO 2');
    
                }
                else{
                    console.log('### getEcid ERRORE! Numero e/o ecid non trovati ###');
                    console.log('### getEcid this.ecid --> ',this.ecid,' ###');
                    const evt = new ShowToastEvent({
                        title: 'Attenzione!',
                        message: 'ContactId e/o ecid non trovati. Verificare e riprovare.',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    
                }
                
            }).catch(err => {
                console.log(err);
            });      
        }
        else{
            this.launchNewCaseWizard();
        }


  
    }

    launchClickToCall(){

        console.log('launchClickToCall START');

        let getAgentIDPromise =  window.TOOLBAR.AGENT.getAgentID();
        let isTimeOver = false;

        let timeout = setTimeout(() => {
            
            console.log("Scattato il timeout della promise, verrà eseguito il codice del timeout");
            isTimeOver = true;
            const evt = new ShowToastEvent({
                title: 'Attenzione!',
                message: 'Non sei collegato alla barra.',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('PRIMA DI launchNewCaseWizard');
            this.launchNewCaseWizard();
            console.log('DOPO launchNewCaseWizard');
        }, 2000);
        
        console.log('DOPO TIMEOUT');

        getAgentIDPromise.then((data) => {
            window.clearTimeout(timeout);
            if (!isTimeOver) {
                console.log('getAgentID SUCCESS');
                if (typeof data !== "undefined") {
                    console.log('data != undefined');
                    window.TOOLBAR.AGENT.getAgentStateByID(data).then((agentState) => {
                        console.log('getAgentStateByID SUCCESS');
                        if (typeof agentState === "object") {
                            console.log('agentState = OBJECT');
                            console.log("ID:", agentState.ID, "FirstLoginTime:", agentState.FirstLoginTime, "agentState:", agentState);
                            this.firstLoginTime = agentState.FirstLoginTime;
                            console.log('ARRIVATO PRIMA DI LANCIO CHECK OPEN SCRIPT');
                            if(agentState.State === 'AGENT:PAUSE'){
                                const evt = new ShowToastEvent({
                                    title: 'Attenzione!',
                                    message: 'Per proseguire verificare che lo stato della barra sia "disponibile". ',
                                    variant: 'warning',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                            }
                            else{
                                this.checkOpenScript();
                            }
                        }
                    }).bind(this), error => {
                        console.log('getAgentStateByID ERROR');
                        console.log(error)
                    };
                }
                console.log("Promise risolta, codice eseguito");
            } else {
                isTimeOver = false
                console.log("Promise risolta dopo il timeout, NON è stato eseguita il codice nella THEN");
            }
        

        }).catch(err => {
                console.log('getAgentIDPromise ERROR');
                console.log(err);
            });                
    }

    //#region Esecuzione gestione Click To Call
    checkOpenScript() {
        console.log('#### START checkOpenScript ####');
        console.log('#### checkOpenScript PUNTO 1 this.ecid --> ',this.ecid,' ####');
        
        let submitEcid = this.ecid;

        let openScriptNotPresent;

        openScriptNotPresent = this.checkValidityOpenScript();

        if(openScriptNotPresent === true){

            window.TOOLBAR.EASYCIM.openScript("", submitEcid, true).then((data => {
                console.log('Nuovo Caso OPENSCRIPT ESEGUITA');

                if(data && data.result == true && data.terminated != true && data.readOnly != true){
                    console.log('openScript data OK');
                    localStorage.setItem("openScript-"+submitEcid , Date.now());
                    this.launchNewCaseWizard();
                    console.log('openScript value saved --> ',localStorage.getItem("openScript-"+submitEcid));
                    console.log('### openScript PUNTO 10 : data --> ',data,' ###');   
                }
                else{
                    console.log('#### openScript PUNTO 10.1 ####');
                    console.log('## openScript readOnly = true #');
                    console.log('## openScript data --> '+JSON.stringify(data));
                    console.log('## openScript data.result --> '+data.result);
                    console.log('## openScript data.terminated --> '+data.terminated);
                    console.log('## openScript data.readOnly --> '+data.readOnly);
                    //####  blocco attività  ####
                    try {
                        console.log('### openScript PUNTO 10.2 ###');
                        //alert("Errore! Non puoi effettuare la chiamata in questo momento.");
                        const evt = new ShowToastEvent({
                            title: 'Errore',
                            message: 'Il contatto è in gestione lato EasyCIM da altro operatore.',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        console.log('#### openScript PUNTO 11 ####');
                    } catch (error) {
                        console.error('openScript ERRORE --> ',error);
                    }
                }
                
            }).bind(this), error => {
                console.log('ERROR')
                console.log(error)
            });
        }
        else{

            console.log('openScript non eseguita perché già effettuata');
            this.launchNewCaseWizard();

        }
    }

    checkValidityOpenScript(){

        let ecidLoginTime;
        let submitEcid = this.ecid;

        if(localStorage.getItem("openScript-"+submitEcid) != null){
            ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);

            if(ecidLoginTime < this.firstLoginTime){
                localStorage.removeItem("openScript-"+submitEcid);
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return true;
        }

    }
    //#endregion


    launchNewCaseWizard() {
        console.log('this.caseObj --> '+JSON.stringify(this.caseObj));
        if(this.caseObj != null && (this.caseObj.AccountId != null || this.caseObj.Lead__c != null)){
            createNewCase({ c: this.caseObj }).then(data => {
    
                console.log('case --> '+JSON.stringify(data));
                
                //navigate to new created case
                if (data != null) {
                    let query = data.split('?')[1];




                    let params = query.split('&');
                    let obj = {};
                    params.forEach(param => {
                        let elem = param.split('=');
                        obj[elem[0]] = elem[1];
                    });
                    this.processType = obj['c__processType'];
                    do{
                        this.processType = this.processType.replace('+',' ');
                    }
                    while(this.processType.includes("+"));

                   // console.log(JSON.stringify(obj));
                  //  window.open('/post-sale-process-new-case?' + query);
                    this[NavigationMixin.GenerateUrl]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "PostSaleProcessNewCase__c"
                        },
                        state: {
                            // c__processType: obj['c__processType'].replace('+',' '),
                            c__processType: this.processType,
                            c__recordTypeName: obj['c__recordTypeName'],
                            c__accid: obj['c__accid'],
                            c__flowName: obj['c__flowName'],
                            c__campaignId: obj['c__campaignId'],
                            c__campaignMemberId: this.recordId,
                            c__ecid: this.ecid,
                            c__campaignMemberStatus: this.campaignMemberStatus,
                            c__isCommunity: this.isCommunity
                        }
                    }).then(url => {
                       window.open(url, "_self");
                    });
                }
            }).catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `${error.status}`,
                        message: `${error.body.message}`,
                        variant: "error"
                    })
                );
            });
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `error`,
                    message: 'Innesca il Processo dalla Pagina dell\'account',
                    variant: "error"
                })
            );
        }
    }

    get manageDisable(){
        return this.CampaignProcessType == 'Nuova Vendita' || this.CampaignProcessType == '';
    }
}