import { LightningElement, api, track, wire} from 'lwc';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';
import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE} from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";


const CLOSED_CSS = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
const OPENED_CSS = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
export default class HdtSupplyCityEnhancedPicklist extends LightningElement {
    
    @api get label(){
        return this._label;
    }
    set label(newValue){
        if(this._label != newValue) this._label = newValue;
    }
    @api inputSupplyCity;
    @api required;
    @api outputSupplyCity;
    @api interviewId;

    @wire(MessageContext)
	messageContext;

    @api validate (){
        console.log("event catched   "+this.eventButton);
        if('cancel' != this.eventButton && 'previous' != this.eventButton){
            let isValid = this.required ? this.outputSupplyCity != null : true;
            let msg = isValid? null : 'Selezionare un comune';
            return { isValid : isValid, errorMessage: msg };
        }
        return { isValid : true, errorMessage: null };
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

    @track textInputValue = null;

    _label = 'Comune di fornitura';
    cityTechnicalData = [];
    cityOptions = [];

    get valueSelected(){
        return this.outputSupplyCity != null && this.outputSupplyCity !== "";
    }
    
    get cityFilteredOptions(){
        this.setContainerCss(CLOSED_CSS);
        if(this.textInputValue != null && this.textInputValue.length > 2){
            let filteredOptions = [];
            this.cityOptions.forEach( curOpt => {
                if(curOpt.value.toUpperCase().includes(this.textInputValue.toUpperCase())) filteredOptions.push(curOpt);
            });
            if(filteredOptions.length > 0) this.setContainerCss(OPENED_CSS);
            return filteredOptions;
        }
        else return null;
    }

    connectedCallback(){
        this.subscribeMC();
        this.outputSupplyCity = this.inputSupplyCity;
        this.call_getCities();
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    call_getCities() {
        console.log('### call_getCities');
        this.showSpinner = true;
        getCities({ })
            .then(result => {
                console.log('### result -> getCities', JSON.stringify(result.length));
                this.cityTechnicalData = result;
                for (var i = 0; i < result.length; i++) {
                    this.cityOptions=[...this.cityOptions,{label: result[i].CadastralCity__c , value: result[i].CadastralCity__c} ];
                }
            })
            .catch(error => {
                console.error("### call_getCities Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleTextKeyup(event) {
        this.textInputValue = event.target.value;
    }

    handleRemoveButton(){
        this.outputSupplyCity = null;
        this.textInputValue = null;
    }

    handleOptionClick(event){
        this.setContainerCss(CLOSED_CSS);
        this.outputSupplyCity = event.target.getAttribute('data-id');
    }

    setContainerCss(cssValue){
        if(this.template.querySelector('[data-id="comboboxContainer"]'))
            this.template.querySelector('[data-id="comboboxContainer"]').setAttribute("class", cssValue);
    }
    
}