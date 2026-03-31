# ===============================
# Navigation
# ===============================

function ..() { cd .. }
function ...() { cd ../.. }
function ....() { cd ../../.. }
function .....() { cd ../../../.. }

function cd-() { cd - > /dev/null }

function ~() { cd $HOME }
