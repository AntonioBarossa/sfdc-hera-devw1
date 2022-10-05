import { LightningElement, track, api, wire } from 'lwc';
import getUniqueString from '@salesforce/apex/HDT_LC_StringGenerationForDocument.getUniqueString';
import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE} from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";


class retainData{
    constructor(dataId, value) {
        this.dataId = dataId;
        this.value=value;

    }
}//Prendere anche data dichiarazione in maniera dinamica

export default class HdtStringGenerationForDocument extends LightningElement {

    @api caseId;
    @api comune;
    @api caseProcess;
    @api caseSubProcess;
    @api numComponenti;
    @api resultString;
    @api interviewId;
    @api isRequired;

    @api errorMessage;

    @track uniqueString;
    @track numberOfLoop;
    @track currNumber;
    @track triplet = [];
    @track showForm = false;
    @track showNumber = true;
    @track lista;
    @track initWrp;
    @track mapInput;

    //subscribe
    @wire(MessageContext)
	messageContext;
    //subscribe

/*
    handleChangeNumber(event){
        this.currNumber = event.detail.value;
        this.numberOfLoop = [];
        for( let i=0; i<event.detail.value; i++){
            let wrp = {number:i, labelNome: 'Nome componente '+i, labelCognome:'Cognome componente '+i, labelCf:'Codice Fiscale componente '+i}
            this.numberOfLoop.push(wrp);
        }
        console.log(this.numberOfLoop);
    }
*/
/*
    handleClickFirst(event){
        
        if(this.currNumber == null || this.currNumber == 0){
            //alert inserire numero 
            return;
        }
        this.showNumber = false;
        this.showString = false;
        this.showForm = true;
    }
*/

    @api validate(){
        console.log("event catched   "+this.eventButton);
        this.unsubscribeToMessageChannel();
        let message, isValid=false;
        if('cancel' != this.eventButton){
            this.mapInput = this.template.querySelectorAll('lightning-input');
            if([...this.mapInput].every(el=> (!el.required || el.value))){
                isValid = true;
                for( let i=0; i<this.currNumber*3; i+=3){
                    if(this.mapInput[i].value){
                        this.resultString = this.resultString+' '+this.mapInput[i].value+' '+this.mapInput[i+1].value+' '+this.mapInput[i+2].value+'; ';
                        console.log(this.resultString);
                    }
                }
                this.showNumber = false;
                this.showForm = false;
            }else{
                message = 'Compilare campi obbligatori';
            }
            if(!isValid){
                window.sessionStorage.setItem(this.interviewId, JSON.stringify(this.outputObject()));
                message = message? message : 'Contattare un\' amministratore';
            }else{
                window.sessionStorage.removeItem(this.interviewId);
            }
        }else{
            isValid=true;
        }
        return { isValid : isValid
            ,errorMessage: message? message : null
        };

    }


    subscribeMC() {
		// recordId is populated on Record Pages, and this component
		// should not update when this component is on a record page.
        this.subscription = subscribe(
            this.messageContext,
            BUTTONMC,
            (mc) => {if(this.interviewId==mc.sessionid) this.eventButton = mc.message},
            //{ scope: APPLICATION_SCOPE }
        );
		// Subscribe to the message channel
	}

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    outputObject(){
        let outputWrp = [];
        this.mapInput.forEach(elem => {
            outputWrp.push(new retainData(elem.getAttribute('data-id'), elem.value));
        });
        return outputWrp;
    }

    async connectedCallback(){
        this.subscribeMC();
        let parsedWrp;
        const oldWrpStr = window.sessionStorage.getItem(this.interviewId);
        if(this.interviewId && oldWrpStr){
            try{
                parsedWrp = JSON.parse(oldWrpStr);
                parsedWrp = parsedWrp.reduce( (result, elem) => {
                    result[elem.dataId] = elem.value ? elem.value : null;
                    return result;
                },{});
            }catch(e){
                console.log(e);
            }
        }
        this.uniqueString = await getUniqueString({comune : this.comune , caseProcess : this.caseProcess , caseSubProcess : this.caseSubProcess});
        this.currNumber = this.numComponenti;
        this.resultString = this.uniqueString[0].FixedString__c.replace('[N°]',this.currNumber);
        this.numberOfLoop = [];
        for( let i=0; i<this.currNumber; i++){
            let wrp = {number:i, labelNome: 'Nome componente '+(i+1), labelCognome:'Cognome componente '+(i+1), labelCf:'Codice Fiscale componente '+(i+1)}
            wrp.valueNome = parsedWrp?.[wrp.labelNome];
            wrp.valueCognome = parsedWrp?.[wrp.labelCognome];
            wrp.valueCf = parsedWrp?.[wrp.labelCf];
            this.numberOfLoop.push(wrp);
        }
        this.showForm = true;
        console.log(this.uniqueString);
    }
}