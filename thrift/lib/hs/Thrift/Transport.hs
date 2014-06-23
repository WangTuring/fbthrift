{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements. See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership. The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License. You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied. See the License for the
-- specific language governing permissions and limitations
-- under the License.
--

module Thrift.Transport
  ( Transport(..)
  , TransportExn(..)
  , TransportExnType(..)
  ) where

import Control.Monad ( liftM, when )
import Control.Monad.IO.Class
import Control.Exception ( Exception, throw )

import Data.Typeable ( Typeable )
import Data.Word

import qualified Data.ByteString.Lazy as LBS
import Data.Monoid

class Transport a where
    tIsOpen :: (MonadIO m) => a -> m Bool
    tClose  :: (MonadIO m) => a -> m ()
    tRead   :: (MonadIO m) => a -> Int -> m LBS.ByteString
    tPeek   :: (MonadIO m) => a -> m Word8
    tWrite  :: (MonadIO m) => a -> LBS.ByteString -> m ()
    tFlush  :: (MonadIO m) => a -> m ()
    tReadAll :: (MonadIO m) => a -> Int -> m LBS.ByteString

    tReadAll _ 0 = return mempty
    tReadAll a len = do
        result <- tRead a len
        let rlen = fromIntegral $ LBS.length result
        when (rlen == 0) (throw $ TransportExn "Cannot read. Remote side has closed." TE_UNKNOWN)
        if len <= rlen
          then return result
          else (result `mappend`) `liftM` tReadAll a (len - rlen)

data TransportExn = TransportExn String TransportExnType
  deriving ( Show, Typeable )
instance Exception TransportExn

data TransportExnType
    = TE_UNKNOWN
    | TE_NOT_OPEN
    | TE_ALREADY_OPEN
    | TE_TIMED_OUT
    | TE_END_OF_FILE
      deriving ( Eq, Show, Typeable )
