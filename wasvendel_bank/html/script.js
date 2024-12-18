let quantity = 0.0;
let quantity2 = 0.0;
let quantity3 = 0.0;
let bankData = {};
let selectedCode = null;  

document.getElementById('right-arrow').addEventListener('click', function() {
    quantity++;
    updateDepositQuantityInput();
});

document.getElementById('left-arrow').addEventListener('click', function() {
    if (quantity > 0) {
        quantity--;
        updateDepositQuantityInput();
    }
});

document.getElementById('right-arrow2').addEventListener('click', function() {
    quantity2++;
    updateWithdrawalQuantityInput();
});

document.getElementById('left-arrow2').addEventListener('click', function() {
    if (quantity2 > 0) {
        quantity2--;
        updateWithdrawalQuantityInput();
    }
});

document.getElementById('right-arrow3').addEventListener('click', function() {
    quantity3++;
    updateTransferQuantityInput();
});

document.getElementById('left-arrow3').addEventListener('click', function() {
    if (quantity3 > 0) {
        quantity3--;
        updateTransferQuantityInput();
    }
});

function updateDepositQuantityInput() {
    document.getElementById('quantity').value = quantity.toFixed(2);
}

function updateWithdrawalQuantityInput() {
    document.getElementById('quantity2').value = quantity2.toFixed(2);
}

function updateTransferQuantityInput() {
    document.getElementById('quantity3').value = quantity3.toFixed(2);
}

document.getElementById('quantity').addEventListener('input', function() {
    const inputValue = parseFloat(this.value);
    if (!isNaN(inputValue) && inputValue >= 0) {
        quantity = inputValue;
    } else {
        this.value = quantity.toFixed(2);
    }
});

document.getElementById('quantity2').addEventListener('input', function() {
    const inputValue = parseFloat(this.value);
    if (!isNaN(inputValue) && inputValue >= 0) {
        quantity2 = inputValue;
    } else {
        this.value = quantity2.toFixed(2);
    }
});

document.getElementById('quantity3').addEventListener('input', function() {
    const inputValue = parseFloat(this.value);
    if (!isNaN(inputValue) && inputValue >= 0) {
        quantity3 = inputValue;
    } else {
        this.value = quantity3.toFixed(2);
    }
});

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.open === true) {
        $('#purchaseMenu').fadeIn();
        $('#walletMenu').fadeIn();

        if (data.price) {
            const unitPrice = parseFloat(data.price);
            document.getElementById('unit-price').textContent = `$${unitPrice.toFixed(2)}`;
            animatePrice(unitPrice, 1500);
        }

        if (data.bankName) {
            document.getElementById('bank-name').textContent = `Welcome to ${data.bankName} bank!`;
        }

        if (data.bankData) {
            bankData = data.bankData;
        }

        if (data.money) {
            walletPrice = parseFloat(data.money);
            document.getElementById('wallet-price').textContent = `$${walletPrice.toFixed(2)}`;
            animatePrice2(walletPrice, 1500); 
        }

        const inventoryButton = document.getElementById('inventory-button-open');
        inventoryButton.style.display = data.enableStorage ? 'block' : 'none';

        if (data.storageData && data.storageData.upgrade) {
            const upgradeOptions = data.storageData.upgrade;
            const dropdownOptionsContainer = document.getElementById('dropdown-options');
            dropdownOptionsContainer.innerHTML = ''; 

            upgradeOptions.forEach(option => {
                const optionDiv = document.createElement('div');
                optionDiv.textContent = `Upgrade to ${option.slot} slots - $${option.price}`;
                optionDiv.dataset.slot = option.slot;
                optionDiv.dataset.price = option.price;

                optionDiv.addEventListener('click', function() {
                    document.getElementById('selected-upgrade').textContent = optionDiv.textContent;
                    dropdownOptionsContainer.style.display = 'none';  
                });

                dropdownOptionsContainer.appendChild(optionDiv);
            });
        }

        const inventoryButton2 = document.getElementById('inventorybuy-button-action');

        if (data.basicSlot && data.basicPrice) {
            inventoryButton2.textContent = `BUY A STORAGE (${data.basicSlot} slots - $${data.basicPrice})`;
        }

        const bankListElement = document.getElementById('bank-list');
            
        if (data.codes) {
            data.codes.sort(function(a, b) {
                return a.localeCompare(b);
            });
        
            let bankListHtml = '<ul>';
            data.codes.forEach(function(code) {
                const sanitizedCode = code.replace(':', '');
                bankListHtml += `<li data-code="${sanitizedCode}">${sanitizedCode}</li>`;
            });
            bankListHtml += '</ul>';
            bankListElement.innerHTML = bankListHtml;
        
            const listItems = bankListElement.querySelectorAll('li');
            listItems.forEach(function(item) {
                item.addEventListener('click', function() {
                    const previouslySelected = bankListElement.querySelector('li.selected');
                    if (previouslySelected) {
                        previouslySelected.classList.remove('selected');
                    }
                
                    item.classList.add('selected');
                    selectedCode = item.getAttribute('data-code'); 
                });
            });
        } else {
            bankListElement.innerHTML = 'Nincsenek elérhető bankok.';
        }

        
    }
    if (data.open === false) {
        closeMenu();
    }
    if (data.update === true) {
        if (data.price) {
            const unitPrice = parseFloat(data.price);
            document.getElementById('unit-price').textContent = `$${unitPrice.toFixed(2)}`;
            animatePrice(unitPrice, 1500);
        }

        if (data.money) {
            const walletPrice = parseFloat(data.money);
            document.getElementById('wallet-price').textContent = `$${walletPrice.toFixed(2)}`;
            animatePrice2(walletPrice, 1500);
        }
    }
});


function animatePrice(targetPrice, duration) {
    const startPrice = 0;
    const startTime = Date.now();
    
    function update() {
        const elapsedTime = Date.now() - startTime;
        const progress = Math.min(elapsedTime / duration, 1);
        const currentPrice = startPrice + (targetPrice - startPrice) * progress;
        
        document.getElementById('unit-price').textContent = `$${currentPrice.toFixed(2)}`;
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }
    
    requestAnimationFrame(update);
}

function animatePrice2(targetPrice, duration) {
    const startPrice = 0;
    const startTime = Date.now();
    
    function update() {
        const elapsedTime = Date.now() - startTime;
        const progress = Math.min(elapsedTime / duration, 1);
        const currentPrice = startPrice + (targetPrice - startPrice) * progress;
        
        document.getElementById('wallet-price').textContent = `$${currentPrice.toFixed(2)}`;
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }
    
    requestAnimationFrame(update);
}

document.getElementById('cancel-button').addEventListener('click', closeMenu);
document.getElementById('cancel-button2').addEventListener('click', closeDepositMenu);
document.getElementById('cancel-button3').addEventListener('click', closeWhitdrawMenu);
document.getElementById('cancel-button4').addEventListener('click', closeTransferMenu);
document.getElementById('cancel-button5').addEventListener('click', closeStorageMenu);
document.getElementById('cancel-button6').addEventListener('click', closeStorageManagementMenu);

document.addEventListener('DOMContentLoaded', function() {

    document.getElementById('deposit-button-open').addEventListener('click', function() {
        closeWhitdrawMenu();
        closeTransferMenu();
        closeStorageMenu();
        closeStorageManagementMenu();
        setTimeout(() => {
            $('#depositMenu').fadeIn();
        }, 400);
    });

    document.getElementById('deposit-button-action').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/Deposit`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                quantity: quantity,
                bankData: bankData
            })
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                closeDepositMenu();
            }
        }).catch(error => {
        });
    });


    document.getElementById('whitdraw-button-open').addEventListener('click', function() {
        closeWhitdrawMenu();
        closeDepositMenu();
        closeTransferMenu();
        closeStorageMenu();
        closeStorageManagementMenu();
        setTimeout(() => {
            $('#whitdrawMenu').fadeIn();
        }, 400);
    });

    document.getElementById('whitdraw-button-action').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/Whitdraw`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                quantity2: quantity2,
                bankData: bankData
            })
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                closeWhitdrawMenu();
            }
        }).catch(error => {
        });
    });


    document.getElementById('transfer-button-open').addEventListener('click', function() {
        closeWhitdrawMenu();
        closeDepositMenu();
        closeStorageMenu();
        closeStorageManagementMenu();
        setTimeout(() => {
            $('#transferMenu').fadeIn();
        }, 400);
    });

    document.getElementById('transfer-button-action').addEventListener('click', function() {
        if (selectedCode === null) {
            return;
        }
    
        fetch(`https://${GetParentResourceName()}/Transfer`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                bankData: bankData,
                quantity3: quantity3,
                selectedBankName: selectedCode 
            })
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                closeTransferMenu();
            }
        }).catch(error => {
        });
    });    

    document.getElementById('inventory-button-open').addEventListener('click', function() {
        closeWhitdrawMenu();
        closeTransferMenu();
        closeDepositMenu();
        closeStorageManagementMenu();
        setTimeout(() => {
            $('#storageMenu').fadeIn();
        }, 400);
    });

    document.getElementById('inventory-button-action').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/Storage`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                bankData: bankData
            })
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                closeDepositMenu();
            }
        }).catch(error => {
        });
    });
    
    document.getElementById('storagemanage-button-action').addEventListener('click', function() {
        closeWhitdrawMenu();
        closeTransferMenu();
        closeStorageMenu();
        closeDepositMenu();
        setTimeout(() => {
            $('#storagemanagementMenu').fadeIn();
        }, 400);
    });

    document.getElementById('selected-upgrade').addEventListener('click', function() {
        const dropdownOptions = document.getElementById('dropdown-options');
        dropdownOptions.style.display = dropdownOptions.style.display === 'none' ? 'block' : 'none';
    });
    

    document.getElementById('inventorybuy-button-action').addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/BuyStorage`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                bankData: bankData
            })
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                closeDepositMenu();
            }
        }).catch(error => {
        });
    });

    document.getElementById('upgrade-button').addEventListener('click', function() {
        const selectedText = document.getElementById('selected-upgrade').textContent;
        const selectedOption = Array.from(document.getElementById('dropdown-options').children)
            .find(option => option.textContent === selectedText);
    
        if (selectedOption) {
            const slot = selectedOption.dataset.slot;
            const price = selectedOption.dataset.price;
    
            fetch(`https://${GetParentResourceName()}/UpgradeStorage`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    bankData: bankData,
                    slot: slot,
                    price: price
                })
            }).then(resp => resp.json()).then(resp => {
                if (resp.success) {
                } else {
                }
            }).catch(error => {
            });
        } else {
        }
    });

});

function closeMenu() {
    $('#purchaseMenu').fadeOut(400);
    $('#whitdrawMenu').fadeOut();
    $('#depositMenu').fadeOut();
    $('#walletMenu').fadeOut();
    $('#transferMenu').fadeOut();
    $('#storageMenu').fadeOut();
    $('#storagemanagementMenu').fadeOut();
    bankData = {};
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST'
    });
}

function closeTransferMenu() {
    $('#transferMenu').fadeOut();
}

function closeWhitdrawMenu() {
    $('#whitdrawMenu').fadeOut();
}

function closeDepositMenu() {
    $('#depositMenu').fadeOut();
}

function closeStorageMenu() {
    $('#storageMenu').fadeOut();
}

function closeStorageManagementMenu() {
    $('#storagemanagementMenu').fadeOut();
}

$(document).keyup(function (e) {
    if (e.keyCode === 27) {
        closeMenu();
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            }
        });
    }
});