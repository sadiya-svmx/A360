import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import labelAutoConfiguration from '@salesforce/label/c.Label_AutoConfigurationIsRequired';
import labelMoreInformation from '@salesforce/label/c.Label_MoreInformation';

import getAllCardData from '@salesforce/apex/ADM_AdminWelcomePage_LS.getAllCardData';
import { parseErrorMessage } from 'c/utils';
import welcomeCardsImg from '@salesforce/resourceUrl/Welcome_Cards';

const i18n = {
    warningMessage: labelAutoConfiguration,
    moreInformationButton: labelMoreInformation
};

export default class AdminWelcome extends NavigationMixin(LightningElement) {
    @track isReady;
    error;
    boxTile = [];
    autoConfigUrl;

    get i18n () {
        return i18n;
    }

    @wire(getAllCardData)
    getCardCallback ({ data, error }) {
        if (data) {
           const formattedData = data.map(listItem => {
                let cardImgUrl;
                if (listItem.cardIcon === 'utility:announcement') {
                    cardImgUrl = `${welcomeCardsImg}/welcomeCard/mod-release.svg`;
                } else if (listItem.cardIcon === 'utility:trail') {
                    cardImgUrl = `${welcomeCardsImg}/welcomeCard/mod-training.svg`;
                } else {
                    cardImgUrl = `${welcomeCardsImg}/welcomeCard/mod-community.svg`;
                }
                return {
                  ...listItem,
                  cardIcon: cardImgUrl,
                };
              });
            this.boxTile = formattedData;
        }
        else if (error) {
            this.error = parseErrorMessage(error);
        }
    }
}