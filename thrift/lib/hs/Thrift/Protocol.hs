{-# LANGUAGE CPP #-}
{-# LANGUAGE DeriveDataTypeable #-}
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

module Thrift.Protocol
    ( Protocol(..)
    , skip
    , MessageType(..)
    , ThriftType(..)
    , ProtocolExn(..)
    , ProtocolExnType(..)
    ) where

import Control.Monad hiding (void)
#if __GLASGOW_HASKELL__ >= 710
import Control.Monad (void)
#endif
import Control.Monad.IO.Class
import Control.Exception
import Data.ByteString.Lazy
import Data.Int
import Data.Text.Lazy (Text)
import Data.Typeable (Typeable)

import Thrift.Transport


data ThriftType
    = T_STOP
    | T_VOID
    | T_BOOL
    | T_BYTE
    | T_DOUBLE
    | T_I16
    | T_I32
    | T_I64
    | T_STRING
    | T_STRUCT
    | T_MAP
    | T_SET
    | T_LIST
    | T_FLOAT
      deriving ( Eq )

instance Enum ThriftType where
    fromEnum T_STOP   = 0
    fromEnum T_VOID   = 1
    fromEnum T_BOOL   = 2
    fromEnum T_BYTE   = 3
    fromEnum T_DOUBLE = 4
    fromEnum T_I16    = 6
    fromEnum T_I32    = 8
    fromEnum T_I64    = 10
    fromEnum T_STRING = 11
    fromEnum T_STRUCT = 12
    fromEnum T_MAP    = 13
    fromEnum T_SET    = 14
    fromEnum T_LIST   = 15
    fromEnum T_FLOAT  = 19

    toEnum 0  = T_STOP
    toEnum 1  = T_VOID
    toEnum 2  = T_BOOL
    toEnum 3  = T_BYTE
    toEnum 4  = T_DOUBLE
    toEnum 6  = T_I16
    toEnum 8  = T_I32
    toEnum 10 = T_I64
    toEnum 11 = T_STRING
    toEnum 12 = T_STRUCT
    toEnum 13 = T_MAP
    toEnum 14 = T_SET
    toEnum 15 = T_LIST
    toEnum 19 = T_FLOAT
    toEnum t = error $ "Invalid ThriftType " ++ show t

data MessageType
    = M_CALL
    | M_REPLY
    | M_EXCEPTION
      deriving ( Eq )

instance Enum MessageType where
    fromEnum M_CALL      =  1
    fromEnum M_REPLY     =  2
    fromEnum M_EXCEPTION =  3

    toEnum 1 = M_CALL
    toEnum 2 = M_REPLY
    toEnum 3 = M_EXCEPTION
    toEnum t = error $ "Invalid MessageType " ++ show t


class Protocol a where
    getTransport :: Transport t => a t -> t

    writeMessageBegin :: (MonadIO m, Transport t) => a t
                         -> (Text, MessageType, Int32) -> m ()
    writeMessageEnd   :: (MonadIO m, Transport t) => a t -> m ()

    writeStructBegin :: (MonadIO m, Transport t) => a t -> Text -> m ()
    writeStructEnd   :: (MonadIO m, Transport t) => a t -> m ()
    writeFieldBegin  :: (MonadIO m, Transport t) => a t
                        -> (Text, ThriftType, Int16) -> m ()
    writeFieldEnd    :: (MonadIO m, Transport t) => a t -> m ()
    writeFieldStop   :: (MonadIO m, Transport t) => a t -> m ()
    writeMapBegin    :: (MonadIO m, Transport t) => a t
                        -> (ThriftType, ThriftType, Int32) -> m ()
    writeMapEnd      :: (MonadIO m, Transport t) => a t -> m ()
    writeListBegin   :: (MonadIO m, Transport t) => a t ->
                        (ThriftType, Int32) -> m ()
    writeListEnd     :: (MonadIO m, Transport t) => a t -> m ()
    writeSetBegin    :: (MonadIO m, Transport t) => a t -> (ThriftType, Int32)
                        -> m ()
    writeSetEnd      :: (MonadIO m, Transport t) => a t -> m ()

    writeBool   :: (MonadIO m, Transport t) => a t -> Bool -> m ()
    writeByte   :: (MonadIO m, Transport t) => a t -> Int8 -> m ()
    writeI16    :: (MonadIO m, Transport t) => a t -> Int16 -> m ()
    writeI32    :: (MonadIO m, Transport t) => a t -> Int32 -> m ()
    writeI64    :: (MonadIO m, Transport t) => a t -> Int64 -> m ()
    writeFloat  :: (MonadIO m, Transport t) => a t -> Float -> m ()
    writeDouble :: (MonadIO m, Transport t) => a t -> Double -> m ()
    writeString :: (MonadIO m, Transport t) => a t -> Text -> m ()
    writeBinary :: (MonadIO m, Transport t) => a t -> ByteString -> m ()


    readMessageBegin :: (MonadIO m, Transport t) => a t
                        -> m (Text, MessageType, Int32)
    readMessageEnd   :: (MonadIO m, Transport t) => a t -> m ()

    readStructBegin :: (MonadIO m, Transport t) => a t -> m Text
    readStructEnd   :: (MonadIO m, Transport t) => a t -> m ()
    readFieldBegin  :: (MonadIO m, Transport t) => a t
                       -> m (Text, ThriftType, Int16)
    readFieldEnd    :: (MonadIO m, Transport t) => a t -> m ()
    readMapBegin    :: (MonadIO m, Transport t) => a t
                       -> m (ThriftType, ThriftType, Int32)
    readMapEnd      :: (MonadIO m, Transport t) => a t -> m ()
    readListBegin   :: (MonadIO m, Transport t) => a t -> m (ThriftType, Int32)
    readListEnd     :: (MonadIO m, Transport t) => a t -> m ()
    readSetBegin    :: (MonadIO m, Transport t) => a t -> m (ThriftType, Int32)
    readSetEnd      :: (MonadIO m, Transport t) => a t -> m ()

    readBool   :: (MonadIO m, Transport t) => a t -> m Bool
    readByte   :: (MonadIO m, Transport t) => a t -> m Int8
    readI16    :: (MonadIO m, Transport t) => a t -> m Int16
    readI32    :: (MonadIO m, Transport t) => a t -> m Int32
    readI64    :: (MonadIO m, Transport t) => a t -> m Int64
    readFloat  :: (MonadIO m, Transport t) => a t -> m Float
    readDouble :: (MonadIO m, Transport t) => a t -> m Double
    readString :: (MonadIO m, Transport t) => a t -> m Text
    readBinary :: (MonadIO m, Transport t) => a t -> m ByteString


skip :: (Protocol p, MonadIO m, Transport t) => p t -> ThriftType -> m ()
skip _ T_STOP = return ()
skip _ T_VOID = return ()
skip p T_BOOL = void $ readBool p
skip p T_BYTE = void $ readByte p
skip p T_I16 = void $ readI16 p
skip p T_I32 = void $ readI32 p
skip p T_I64 = void $ readI64 p
skip p T_FLOAT = void $ readFloat p
skip p T_DOUBLE = void $ readDouble p
skip p T_STRING = void $ readString p
skip p T_STRUCT = do _ <- readStructBegin p
                     skipFields p
                     readStructEnd p
skip p T_MAP = do (k, v, s) <- readMapBegin p
                  replicateM_ (fromIntegral s) (skip p k >> skip p v)
                  readMapEnd p
skip p T_SET = do (t, n) <- readSetBegin p
                  replicateM_ (fromIntegral n) (skip p t)
                  readSetEnd p
skip p T_LIST = do (t, n) <- readListBegin p
                   replicateM_ (fromIntegral n) (skip p t)
                   readListEnd p


skipFields :: (Protocol p, MonadIO m, Transport t) => p t -> m ()
skipFields p = do
    (_, t, _) <- readFieldBegin p
    unless (t == T_STOP) (skip p t >> readFieldEnd p >> skipFields p)

data ProtocolExnType
    = PE_UNKNOWN
    | PE_INVALID_DATA
    | PE_NEGATIVE_SIZE
    | PE_SIZE_LIMIT
    | PE_BAD_VERSION
    | PE_NOT_IMPLEMENTED
    | PE_MISSING_REQUIRED_FIELD
      deriving ( Eq, Show, Typeable )

data ProtocolExn = ProtocolExn ProtocolExnType String
  deriving ( Show, Typeable )
instance Exception ProtocolExn

#if __GLASGOW_HASKELL__ < 710
void :: (Monad m) => m a -> m ()
void = liftM (const ())
#endif
