{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}

module Pixura.Contracts.ZeroX.ERC20Proxy where

import           Network.Ethereum.Contract.TH

[abiFrom|contracts/no-gen-abis/ERC20Proxy.json|]
