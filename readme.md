# Newman-Run-Report
Postman�̕������N�G�X�g�������e�X�g���A���ʂ����|�[�g���܂��B
�܂��ASlack�ɒʒm���܂��B


## Dependency
Windows Powershell 3.0�ȏ�  
Node.js via package manager v6�ȏ�  
Newman v4

## Setup
1. Newman���C���X�g�[�� ```npm install -g newman```

2. Postman�ɂ�collection���G�N�X�|�[�g�ijson�`���j

3. collection.json��Report.ps1�Ɠ����f�B���N�g���ɔz�u

4. Report.ps1����`#`�ň͂܂ꂽ������C�ӂ̖��O�ɕύX



## Usage
Report.ps1���N������Ǝ����I�Ƀe�X�g���s���A���|�[�g�� `.\newman`���ɋL�^�����

�^�X�N�X�P�W���[���g�p�ł𗘗p�̍ۂ�Windows�ɓ��ڂ���Ă���^�X�N�X�P�W���[�����X�P�W���[���ݒ肪�ł���

### �^�X�N�X�P�W���[���v���p�e�B  
#### �S��  
 �ŏ�ʂ̓����Ŏ��s

#### ����  
 �v���O����/�X�N���v�g  task-scheduler.js�̃p�X����� Ex`C:\Newman-Run-Report\�^�X�N�X�P�W���[���g�p��\task-scheduler.js`  
 �����̒ǉ�  Report.ps1�̃p�X����� Ex`"C:\Newman-Run-Report\�^�X�N�X�P�W���[���g�p��\Report.ps1"`  
���̑��̃v���p�e�B�͔C��  

## Licence
This software is released under the MIT License, see LICENSE.

## Authors
* **sumasi** [sumasi Room](https://github.com/sumasi52)


## References
https://www.npmjs.com/package/newman#newman-the-cli-companion-for-postman  
https://api.slack.com/incoming-webhooks