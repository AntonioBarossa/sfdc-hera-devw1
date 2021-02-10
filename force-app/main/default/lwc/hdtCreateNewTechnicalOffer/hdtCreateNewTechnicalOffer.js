import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtCreateNewTechnicalOffer extends NavigationMixin(LightningElement) {

    showWelcom = true;
    showSearchOffer = false;
    showCreateOffer = false;
    @api productid;

    handleClick(event){
        console.log('### productid -> ' + this.productid);
    }

    closeModal(event){
        console.log('### Parent closeModal ###');
        console.log('### return to-> ' + this.productid);

        const goback = new CustomEvent('goback', {
            detail: {prodId: this.productid}
        });
        // Fire the custom event
        this.dispatchEvent(goback);

        //this[NavigationMixin.Navigate]({
        //    type: 'standard__recordPage',
        //    attributes: {
        //        recordId: this.productid,
        //        objectApiName: 'Product2',
        //        actionName: 'view'
        //    }
        //});
        //this.showWelcom = false;
    }

    createNew(event){
        console.log('### Parent createNew ###');
        this.showWelcom = false;
        this.showCreateOffer = true;
    }

    search(event){
        console.log('### Parent search ###');
        this.showWelcom = false;
        this.showSearchOffer = true;
    }

    closeSearch(event){
        this.showWelcom = true;
        this.showSearchOffer = false;
        
        console.log('### return to-> ' + this.productid);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productid,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });

    }

}
