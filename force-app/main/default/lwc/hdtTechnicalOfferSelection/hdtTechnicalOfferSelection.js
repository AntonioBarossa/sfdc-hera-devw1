import { LightningElement, api, wire } from 'lwc';
import getRateList from '@salesforce/apex/HDT_LC_OfferConfiguratorController.getRateList';

export default class HdtTechnicalOfferSelection extends LightningElement {

    @api tiles;
    @api iconName;
    @api mainTitleLabel;
    @api newTitleLabel;
    @api searchTitleLabel;
    rateList;
    showRate = false;
    showSelection = true;
    eventName;
    queryTerm = '';

    connectedCallback(){
        //enableCreate: false,
        //hasRecords: false,
        //records: []
        this.class1 = (this.tiles.enableCreate) ? 'slds-box slds-box_link slds-media' : 'slds-box slds-box_link slds-media isDisabled';
    }

    @wire(getRateList, {queryTerm : '$queryTerm'})
    wiredRare({error, data}) {
        if(data) {
            this.rateList = data;
        } else if (error) {
            this.error = error;
        }
    }

    closeModal(event){
        console.log('### closeModal ###');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    createNew(event){
        console.log('### createNew ###');
        if(this.tiles.enableCreate){
            this.showRate = true;
            this.showSelection = false;
            this.eventName = 'createnew';
        }
    }

    search(event){
        console.log('### search ###');
        if(this.tiles.enableCreate){
            this.showRate = true;
            this.showSelection = false;
            this.eventName = 'search';
        }
    }

    handleKeyUp(evt) {
        console.log('>>> handleKeyUp');
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
        }
    }

    handleSearch(event){
        console.log('>>>>');
        if(this.queryTerm != null && this.queryTerm != '' && this.queryTerm != undefined){
            this.queryTerm = '';
        }
    }

    selectRate(event){
        console.log('### selectRate ###');
        var dataset = event.currentTarget.dataset;
        this.dispatchCustomEvent(dataset.id, dataset.name, dataset.temp);
    }

    dispatchCustomEvent(selectedRateId, selectedRateName, selectedRateTemplate){
        const customEvent = new CustomEvent(this.eventName, {
            detail:  {rateId: selectedRateId, rateName: selectedRateName, rateTemplate: selectedRateTemplate}
        });
        // Dispatches the event.
        this.dispatchEvent(customEvent);
    }

    selectOffer(event){
        console.log('### selectOffer ###');
        console.log('>>> ' + event.currentTarget.dataset.id);
        console.log('>>> ' + event.currentTarget.dataset.temp);
        console.log('>>> ' + event.currentTarget.dataset.rate);
        const selectOffer = new CustomEvent("selectoffer", {
            detail: {id: event.currentTarget.dataset.id, temp: event.currentTarget.dataset.temp, rate: event.currentTarget.dataset.rate}
        });

        // Dispatches the event.
        this.dispatchEvent(selectOffer);
    }

}