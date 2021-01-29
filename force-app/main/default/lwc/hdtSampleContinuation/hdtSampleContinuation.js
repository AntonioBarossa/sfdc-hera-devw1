import { LightningElement } from 'lwc';
import callMulesoft from '@salesforce/apexContinuation/SampleContinuationClass.startRequest';

export default class SampleContinuation extends LightningElement {

    backendCall(){
        console.log('# Get data from Mulesoft #');

        callMulesoft({techObj: 'value1', requestObj: 'value2'})
            .then(result => {
                console.log('# Mulesoft result #');
                console.log('# success: ' + result.success);

                if(result.success){
                    console.log('----> ' + result.message);
                } else {
                    console.log('----> ' + result.message);
                }
               
            })
            .catch(error => {

            });

    }

}