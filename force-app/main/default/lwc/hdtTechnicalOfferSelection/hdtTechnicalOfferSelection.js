import { LightningElement, api, wire } from 'lwc';
import getRateList from '@salesforce/apex/HDT_LC_OfferConfiguratorController.getRateList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import offerSelection from '@salesforce/label/c.HDT_LWC_OfferSelectionLabel';

export default class HdtTechnicalOfferSelection extends LightningElement {

    label = {
        offerSelection
    };

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

        console.log('>>> ' + JSON.stringify(this.tiles.records));
        console.log('>>> ' + JSON.stringify(event.currentTarget.dataset));

        //[{"id":"a321x000000aPktAAE","name":"ProductTest [V1] [ELVND_FC01]","rateTemp":"ZELE_PREZZO","rateName":"ELVND_FC01"}]
        //{"id":"a2j1x000004d8e1AAA","name":"ELVND_FC01","temp":"ZELE_PREZZO","servProduct":"ELE_PREZZO"}

        var rateArray = [];

        this.tiles.records.forEach(item => {
            rateArray.push(item.rateName);
        });

        if(rateArray.includes(event.currentTarget.dataset.name)){
            const evt = new ShowToastEvent({
                title: 'ATTENZIONE',
                message: 'Hai già creato un\'offerta con la category ' + event.currentTarget.dataset.name,
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        } else {
            var dataset = event.currentTarget.dataset;
            this.dispatchCustomEvent(dataset.id, dataset.name, dataset.temp, dataset.servProduct);
        }

    }

    dispatchCustomEvent(selectedRateId, selectedRateName, selectedRateTemplate, selectedServProduct){
        const customEvent = new CustomEvent(this.eventName, {
            detail:  {rateId: selectedRateId, rateName: selectedRateName, rateTemplate: selectedRateTemplate, servProduct: selectedServProduct}
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