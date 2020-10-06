<?php

$PASS = "ikshdrht9er5guh9saer54ghsaourfbsarT$#W%gw4t6g";

function fnEncrypt($str) {
    return strToHex(rtrim(
        base64_encode(
            mcrypt_encrypt(
                MCRYPT_RIJNDAEL_256,
                $GLOBALS["PASS"], $str,
                MCRYPT_MODE_ECB,
                mcrypt_create_iv(
                    mcrypt_get_iv_size(
                        MCRYPT_RIJNDAEL_256,
                        MCRYPT_MODE_CBC
                    ),
                    MCRYPT_RAND)
                )
            ), "\0"
        ));
}

function fnDecrypt($str) {
    return (rtrim(
        mcrypt_decrypt(
            MCRYPT_RIJNDAEL_256,
            $GLOBALS["PASS"],
            base64_decode(hexToStr($str)),
            MCRYPT_MODE_ECB,
            mcrypt_create_iv(
                mcrypt_get_iv_size(
                    MCRYPT_RIJNDAEL_256,
                    MCRYPT_MODE_CBC
                ),
                MCRYPT_RAND
            )
        ), "\0"
    ));
}

function strToHex($string)
{
    $hex='';
    for ($i=0; $i < strlen($string); $i++){
        $hex .= dechex(ord($string[$i]));
    }
    return $hex;
}

function hexToStr($hex)
{
    $string='';
    for ($i=0; $i < strlen($hex)-1; $i+=2){
        $string .= chr(hexdec($hex[$i].$hex[$i+1]));
    }
    return $string;
	}

?>
