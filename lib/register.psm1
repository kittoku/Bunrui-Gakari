I m p o r t - M o d u l e   - N a m e   ( J o i n - P a t h   - P a t h   $ e n v : B G _ l i b   - C h i l d P a t h   m i s c . p s m 1 )   - D i s a b l e N a m e C h e c k i n g   - f u n c t i o n   *  
 I m p o r t - M o d u l e   - N a m e   ( J o i n - P a t h   - P a t h   $ e n v : B G _ l i b   - C h i l d P a t h   t a x a . p s m 1 )   - D i s a b l e N a m e C h e c k i n g   - f u n c t i o n   *  
 I m p o r t - M o d u l e   - N a m e   ( J o i n - P a t h   - P a t h   $ e n v : B G _ l i b   - C h i l d P a t h   p a t h . p s m 1 )   - D i s a b l e N a m e C h e c k i n g   - f u n c t i o n   *  
  
  
 f u n c t i o n   _ S e l e c t - T y p e  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ T a x o n  
         )  
  
         D e l i m i t   ' �OX[:SRn0x��b'  
  
         W r i t e T a b   ' 1 :   i�-N'  
         W r i t e T a b   ' 2 :   �2�(u'  
  
         L o o p - B l o c k   - B l o c k   {  
                 $ i n t e n t   =   R e a d L n   " x��bY0�0�OX[:SRn0ju�S�0JS҉peW[g0eQ�RW0f0O0`0U0D0"  
  
                 i f   ( $ i n t e n t   - e q   ' 1 ' )  
                 {  
                         $ T a x o n . t y p e   =   ' i�-N'  
                 }  
                 e l s e i f   ( $ i n t e n t   - e q   ' 2 ' )  
                 {  
                         $ T a x o n . t y p e   =   ' �2�(u'  
                 }  
                 e l s e  
                 {  
                         t h r o w   ' !q�Rj0�eW[L0eQ�RU0�0~0W0_0'  
                 }  
         }  
  
         H i g h l i g h t - I n t e n t   - I n t e n t   $ T a x o n . t y p e   - S u f f i x   ' L0x��bU0�0~0W0_0'  
 }  
  
 f u n c t i o n   _ S e l e c t - T a x o n  
 {  
         [ O u t p u t T y p e ( [ S y s t e m . X m l . X m l N o d e ] ) ]  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ T a x o n ,  
  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ A r r a y ] $ N o d e s ,  
  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ S t r i n g ] $ L e v e l  
         )  
  
         D e l i m i t   " $ { L e v e l } n0x��b"  
  
         $ t a b l e   =   @ {   }  
         f o r e a c h   ( $ n o d e   i n   $ N o d e s )  
         {  
                 i f   ( $ L e v e l   - e q   ' \R^�' )  
                 {  
                         $ c o d e   =   $ n o d e . A t t r i b u t e s . I t e m O f ( ' �0�0�0' ) . V a l u e  
                         $ n a m e   =   $ n o d e . A t t r i b u t e s . I t e m O f ( ' T�y' ) . V a l u e  
                         $ r e m a r k   =   $ n o d e . A t t r i b u t e s . I t e m O f ( ' �P�' ) . V a l u e  
                         $ f r e q u e n c y   =   $ n o d e . A t t r i b u t e s . I t e m O f ( ' ;��^' ) . V a l u e  
  
                         W r i t e T a b   " $ { c o d e } :   $ { n a m e }         [ $ { r e m a r k } ] [ $ { f r e q u e n c y } ] "  
  
                 }  
                 e l s e  
                 {  
                         $ c o d e   =   $ n o d e . A t t r i b u t e s . I t e m O f ( ' �0�0�0' ) . V a l u e  
                         $ n a m e   =   $ n o d e . A t t r i b u t e s . I t e m O f ( ' T�y' ) . V a l u e  
  
                         W r i t e T a b   " $ { c o d e } :   $ { n a m e } "  
                 }  
  
                 $ t a b l e . A d d ( $ c o d e ,   $ n o d e )  
         }  
  
  
         $ s e l e c t e d   =   L o o p - B l o c k   - B l o c k   {  
                 $ i n t e n t   =   R e a d L n   " x��bY0�0$ { L e v e l } �0�0�0�0JS҉�peg0eQ�RW0f0O0`0U0D0"  
  
                 i f   ( ! ( $ t a b l e . C o n t a i n s K e y ( $ i n t e n t ) ) )  
                 {  
                         t h r o w   ' !q�Rj0�eW[L0eQ�RU0�0~0W0_0'  
                 }  
  
                 r e t u r n   $ t a b l e . $ i n t e n t  
         }  
  
         U p d a t e - T a x o n   - T a x o n   $ T a x o n   - N o d e   $ s e l e c t e d   - L e v e l   $ L e v e l  
  
         H i g h l i g h t - I n t e n t   - P r e f i x   " $ { L e v e l } "   - S u f f i x   " L0x��bU0�0~0W0_0"   `  
                 - I n t e n t   ( " $ (   $ s e l e c t e d . A t t r i b u t e s . I t e m O f ( ' �0�0�0' ) . V a l u e   ) - "   +  
                         " $ (   $ s e l e c t e d . A t t r i b u t e s . I t e m O f ( ' T�y' ) . V a l u e   ) " )  
  
         r e t u r n   $ s e l e c t e d  
 }  
  
 f u n c t i o n   _ S e l e c t - D a t e  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ E n t i t y  
         )  
  
         D e l i m i t   ' \Ob�eBfn0-��['  
  
         L o o p - B l o c k   - B l o c k   {  
                 $ i n t e n t   =   R e a d L n   (  
                 " \Ob�eBf�0JS҉peW[g0eQ�RW0f0O0`0U0D0( �O:   2 0 2 0 t^4 g1 �e  �!  2 0 2 0 0 4 0 1 ) "   `  
                             +   " ` r ` n UO�0eQ�RU0�0j0D04XT0�N�en0�e�NL0��R�vk0-��[U0�0~0Y0"  
                 )  
  
                 i f   ( $ i n t e n t   - e q   " " )  
                 {  
                         $ E n t i t y . d a t e   =   G e t - D a t e   - H o u r   0   - M i n u t e   0   - S e c o n d   0   - M i l l i s e c o n d   0  
                 }  
                 e l s e  
                 {  
                         $ E n t i t y . d a t e   =   T o - D a t e T i m e   - D a t e   $ i n t e n t  
                 }  
         }  
  
         $ y e a r   =   $ E n t i t y . d a t e . Y e a r  
         i f   ( $ E n t i t y . d a t e . M o n t h   - l t   4 )  
         {  
                 $ y e a r   - =   1  
         }  
  
         $ E n t i t y . t a x o n . n e n d o   =   G e t - D a t e   - Y e a r   $ y e a r   - M o n t h   4   - D a y   1   `  
                 - H o u r   0   - M i n u t e   0   - S e c o n d   0   - M i l l i s e c o n d   0  
  
         H i g h l i g h t - I n t e n t   - S u f f i x   " L0x��bU0�0~0W0_0"   `  
                 - I n t e n t   ( " [ { 0 } ]   { 1 } t^{ 2 } g{ 3 } �e"   - f   `  
                 ( T o - N e n d o   - D a t e   $ E n t i t y . t a x o n . n e n d o   - F o r T a x o n   $ t r u e ) ,     `  
                   $ E n t i t y . d a t e . Y e a r ,   $ E n t i t y . d a t e . M o n t h ,   $ E n t i t y . d a t e . d a y )  
 }  
  
 f u n c t i o n   _ S e l e c t - R e m a r k  
 {  
         [ O u t p u t T y p e ( [ S t r i n g ] ) ]  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ E n t i t y ,  
  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ S y s t e m . X m l . X m l D o c u m e n t ] $ X m l  
         )  
  
         D e l i m i t   ' �0�0�0�0�P�n0-��['  
  
         $ t a b l e   =   @ {   }  
         $ i   =   0  
  
         f o r e a c h   ( $ e l e m e n t   i n   $ x m l . S e l e c t S i n g l e N o d e ( ' r o o t ' ) . S e l e c t S i n g l e N o d e ( ' �0�0�0�0�P�' ) . S e l e c t N o d e s ( ' �� }' ) )  
         {  
                 $ i + +  
  
                 W r i t e T a b   " $ { i } :   $ (   $ e l e m e n t . I n n e r T e x t   ) "  
  
                 $ t a b l e . A d d ( $ i . T o S t r i n g ( ) ,   $ e l e m e n t . I n n e r T e x t )  
         }  
  
         L o o p - B l o c k   - B l o c k   {  
                 $ i n t e n t   =   R e a d L n   (  
                 " x��bY0�0�0�0�0�0�P�n0ju�S�0JS҉peW[g0eQ�RW0f0O0`0U0D0"   `  
                             +   " ` r ` n UO�0eQ�RU0�0j0D04XT0�0�0�0�0�P�o0-��[U0�0~0[0�0"  
                 )  
  
                 i f   ( $ i n t e n t   - e q   ' ' )  
                 {  
                         $ E n t i t y . r e m a r k   =   ' '  
                 }  
                 e l s e i f   ( $ t a b l e . C o n t a i n s K e y ( $ i n t e n t ) )  
                 {  
                         $ E n t i t y . r e m a r k   =   $ t a b l e . $ i n t e n t  
                 }  
                 e l s e  
                 {  
                         t h r o w   ' !q�Rj0�eW[L0eQ�RU0�0~0W0_0'  
                 }  
         }  
  
         i f   ( $ n u l l   - e q   $ E n t i t y . r e m a r k )  
         {  
                 H i g h l i g h t - I n t e n t   - P r e f i x   ' �0�0�0�0�P�o0'   - I n t e n t   ' -��[U0�0~0[0�0'  
         }  
         e l s e  
         {  
                 H i g h l i g h t - I n t e n t   - P r e f i x   ' �0�0�0�0�P�'   - S u f f i x   ' L0-��[U0�0~0W0_0'   `  
                         - I n t e n t   $ E n t i t y . r e m a r k  
         }  
 }  
  
 f u n c t i o n   _ E q u a l - E n t i t y  
 {  
         [ O u t p u t T y p e ( [ B o o l e a n ] ) ]  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ L e f t ,  
  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ R i g h t  
         )  
  
         f o r e a c h   ( $ p r o p e r t y   i n   @ ( ' d a t e ' ,   ' n a m e ' ) )  
         {  
                 i f   ( $ l e f t . $ p r o p e r t y   - n e   $ r i g h t . $ p r o p e r t y )  
                 {  
                         r e t u r n   $ f a l s e  
                 }  
         }  
  
         r e t u r n   $ t r u e  
 }  
  
 f u n c t i o n   _ M o v e - E n t i t y  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ E n t i t y  
         )  
  
         $ p o s t e d _ p a t h   =   J o i n - P a t h   - P a t h   $ e n v : B G _ p o s t   - C h i l d P a t h   $ E n t i t y . n a m e  
  
         $ r e l a t i v e _ p a t h   =   J o i n - P a t h   - P a t h   ( C o n s t r u c t - P a t h   - T a x o n   $ E n t i t y . t a x o n )   `  
                 - C h i l d P a t h   ( C o n s t r u c t - F i l e N a m e   - E n t i t y   $ E n t i t y )  
  
         $ d s t _ p a t h   =   J o i n - P a t h   - P a t h   $ e n v : B G _ s a v e   - C h i l d P a t h   $ r e l a t i v e _ p a t h  
  
         M o v e - I t e m   - P a t h   $ p o s t e d _ p a t h   - D e s t i n a t i o n   $ d s t _ p a t h  
 }  
  
 f u n c t i o n   _ G e t - P o s t e d  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ E n t i t y  
         )  
  
         f o r e a c h   ( $ i n f o   i n   G e t - C h i l d I t e m   - P a t h   $ e n v : B G _ p o s t )  
         {  
                 i f   ( $ i n f o . n a m e . S u b s t r i n g ( 0 ,   1 )   - e q   ' _ ' )  
                 {  
                         c o n t i n u e  
                 }  
  
                 $ c o p i e d   =   C o p y - E n t i t y ( $ E n t i t y )  
  
                 i f   ( $ I n f o   - i s   [ S y s t e m . I O . D i r e c t o r y I n f o ] )  
                 {  
                         $ c o p i e d . t y p e   =   ' �0�0�0�0'  
                 }  
                 e l s e  
                 {  
                         $ c o p i e d . t y p e   =   ' �0�0�0�0'  
                 }  
  
                 $ c o p i e d . n a m e   =   $ i n f o . n a m e  
  
                 W r i t e - O u t p u t   $ c o p i e d  
         }  
 }  
  
 f u n c t i o n   _ G e t - E x i s t i n g s  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ S t r i n g ] $ P a t h  
         )  
  
         f o r e a c h   ( $ c h i l d   i n   ( G e t - C h i l d I t e m   - P a t h   $ d s t ) )  
         {  
                 W r i t e - O u t p u t   ( P a r s e - F i l e N a m e   - I n f o   $ c h i l d )  
         }  
 }  
  
 f u n c t i o n   _ C h e c k - D u p l i c a t i o n  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ A r r a y ] $ N e w ,  
  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ A r r a y ] $ O l d  
         )  
  
         f o r e a c h   ( $ l e f t   i n   $ N e w )  
         {  
                 f o r e a c h   ( $ r i g h t   i n   $ O l d )  
                 {  
                         i f   ( _ E q u a l - E n t i t y   - L e f t   $ l e f t   - R i g h t   $ r i g h t )  
                         {  
                                 $ l e f t . r e v i s i o n   =   [ M a t h ] : : M a x ( $ l e f t . r e v i s i o n ,   $ r i g h t . r e v i s i o n   +   1 )  
                         }  
                 }  
         }  
 }  
  
 f u n c t i o n   _ F i l l - H o l d e r  
 {  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ T a x o n  
         )  
  
         D e l i m i t   ' �eW[Rn0?ceQ'  
  
         W r i t e L n   ( " \R^�  $ (   $ T a x o n . s m a l l _ n a m e   )   k0o0�eW[R�0?ceQY0�0�_��L0B0�0~0Y0` r ` n "   `  
                   +   ' �Nn0\R^�h0T�yn0teT'`�0�Od0�0F0hQ҉�JS҉�AhpeI{k0�laW0f0eQ�RW0f0O0`0U0D0' )  
  
         $ i n d e x   =   0  
         w h i l e   ( $ t r u e )  
         {  
                 $ h o l d e r   =   " { $ { i n d e x } } "  
                 i f   (   $ T a x o n . s m a l l _ n a m e . C o n t a i n s ( $ h o l d e r ) )  
                 {  
                         $ i n t e n t   =   R e a d L n   " $ { h o l d e r } n0MOnk0eQ�0�eW[R�0eQ�RW0f0O0`0U0D0"  
                         H i g h l i g h t - I n t e n t   - I n t e n t   $ i n t e n t   - S u f f i x   ' L0eQ�RU0�0~0W0_0'  
  
                         $ T a x o n . s m a l l _ n a m e   =   $ T a x o n . s m a l l _ n a m e . R e p l a c e ( $ h o l d e r ,   $ i n t e n t )  
                 }  
                 e l s e  
                 {  
                         b r e a k  
                 }  
  
                 $ i n d e x + +  
         }  
 }  
  
 f u n c t i o n   _ F o r m a t - S m a l l N a m e  
 {  
         [ O u t p u t T y p e ( [ S t r i n g ] ) ]  
         p a r a m   (  
                 [ P a r a m e t e r ( M a n d a t o r y   =   $ t r u e ) ]  
                 [ P S C u s t o m O b j e c t ] $ T a x o n  
         )  
  
         $ b a s e _ n a m e   =   $ T a x o n . s m a l l _ n a m e  
  
         i f   ( $ T a x o n . f r e q u e n c y   - e q   ' �kt^�^' )  
         {  
                 $ n e n d o   =   T o - N e n d o   - d a t e   $ T a x o n . n e n d o   - F o r T a x o n   $ f a l s e  
  
                 i f   ( $ T a x o n . f o r m a t   - e q   ' �_n' )  
                 {  
                         $ T a x o n . s m a l l _ n a m e   =   " $ { $ b a s e _ n a m e } �$ { n e n d o } 	�"  
                 }  
                 e l s e i f   ( $ T a x o n . f o r m a t   - e q   ' :SR' )  
                 {  
                         $ T a x o n . s m a l l _ n a m e   =   " $ { n e n d o }  0$ { b a s e _ n a m e } "  
                 }  
                 e l s e  
                 {  
                         $ T a x o n . s m a l l _ n a m e   =   " $ { n e n d o } $ { b a s e _ n a m e } "  
                 }  
         }  
         e l s e  
         {  
                 $ T a x o n . s m a l l _ n a m e   =   $ b a s e _ n a m e  
         }  
 }  
  
 f u n c t i o n   R e g i s t e r - F i l e  
 {  
         p a r a m   ( )  
  
         $ t a x o n   =   G e t - T a x o n T e m p l a t e  
         $ x m l   =   G e t - C u r r e n t T a x a  
  
         _ S e l e c t - T y p e   - T a x o n   $ t a x o n  
  
         $ l a r g e   =   _ S e l e c t - T a x o n   - L e v e l   ' 'YR^�'   - T a x o n   $ t a x o n   `  
                 - N o d e s   ( S o r t - B y C o d e   - N o d e s   ( $ x m l . S e l e c t S i n g l e N o d e ( ' r o o t ' ) . S e l e c t N o d e s ( ' 'YR^�' ) ) )  
  
         $ m e d i u m   =   _ S e l e c t - T a x o n   - L e v e l   ' -NR^�'   - T a x o n   $ t a x o n   `  
                 - N o d e s   ( S o r t - B y C o d e   - N o d e s   ( $ l a r g e . S e l e c t N o d e s ( ' -NR^�' ) ) )  
  
         $ s m a l l   =   _ S e l e c t - T a x o n   - L e v e l   ' \R^�'   - T a x o n   $ t a x o n   `  
                 - N o d e s   ( S o r t - B y C o d e   - N o d e s   ( $ m e d i u m . S e l e c t N o d e s ( ' \R^�' ) ) )  
  
         i f   (   $ t a x o n . s m a l l _ n a m e . C o n t a i n s ( ' { 0 } ' ) )  
         {  
                 _ F i l l - H o l d e r   - T a x o n   $ t a x o n  
         }  
  
         $ b a s i c _ e n t i t y   =   G e t - E n t i t y T e m p l a t e  
         $ b a s i c _ e n t i t y . t a x o n   =   $ t a x o n  
         $ b a s i c _ e n t i t y . r e v i s i o n   =   0  
  
         _ S e l e c t - D a t e   - E n t i t y   $ b a s i c _ e n t i t y  
         _ S e l e c t - R e m a r k   - E n t i t y   $ b a s i c _ e n t i t y   - X m l   $ x m l  
  
         _ F o r m a t - S m a l l N a m e   - T a x o n   $ b a s i c _ e n t i t y . t a x o n  
  
         $ d s t   =   J o i n - P a t h   - P a t h   $ e n v : B G _ s a v e   - C h i l d P a t h   ( C o n s t r u c t - P a t h   - T a x o n   $ b a s i c _ e n t i t y . t a x o n )  
  
         [ A r r a y ] $ p o s t e d   =   _ G e t - P o s t e d   - E n t i t y   $ b a s i c _ e n t i t y  
         i f   ( $ p o s t e d . C o u n t   - e q   0 )  
         {  
                 t h r o w   ' �0�0�0k0��X��S��j0�0�0�0�0L0eQc0f0D0~0[0�0'  
         }  
  
         $ i s E x i s t i n g   =   T e s t - P a t h   - P a t h   $ d s t   - P a t h T y p e   C o n t a i n e r  
  
         i f   ( $ i s E x i s t i n g )  
         {  
                 [ A r r a y ] $ e x i s i t i n g s   =   _ G e t - E x i s t i n g s   - P a t h   $ d s t  
         }  
         e l s e  
         {  
                 $ e x i s i t i n g s   =   @ ( )  
         }  
  
         i f   ( $ e x i s i t i n g s . C o u n t   - g t   0 )  
         {  
                 _ C h e c k - D u p l i c a t i o n   - N e w   $ p o s t e d   - O l d   $ e x i s i t i n g s  
         }  
  
  
         D e l i m i t   ' �0�0�0�0n0{v2�'  
  
         f o r e a c h   ( $ e n t i t y   i n   $ p o s t e d )  
         {  
                 W r i t e T a b   ( C o n s t r u c t - F i l e N a m e   - E n t i t y   $ e n t i t y )  
         }  
  
         $ s e l e c t e d   =   L o o p - B l o c k   - B l o c k   {  
                 H i g h l i g h t - I n t e n t   - P r e f i x   " ` r ` n �N
Nn0�0�0�0�0L0` r ` n "   - S u f f i x   " ` r ` n k0\ObU0�0~0Y0"   `  
                         - I n t e n t   $ d s t  
  
                 $ i n t e n t   =   R e a d L n   ( ' �0�0W0D0g0Y0K0�0 gB}�x��0[ Y / n ] ' )  
  
                 i f   ( ( $ i n t e n t   - n e   ' Y ' )   - a n d   ( $ i n t e n t   - n e   ' n ' ) )  
                 {  
                         t h r o w   ' !q�Rj0�eW[L0eQ�RU0�0~0W0_0'  
                 }  
  
                 r e t u r n   $ i n t e n t  
         }  
  
         i f   ( $ s e l e c t e d   - e q   ' Y ' )  
         {  
                 i f   ( ! $ i s E x i s t i n g )  
                 {  
                         [ V o i d ] ( N e w - I t e m   - P a t h   $ d s t   - I t e m T y p e   D i r e c t o r y )  
                 }  
  
                 f o r e a c h   ( $ e n t i t y   i n   $ p o s t e d )  
                 {  
                         _ M o v e - E n t i t y   - E n t i t y   $ e n t i t y  
                 }  
  
                 W r i t e L n   ' �0�0�0�0n0{v2�L0�[�NW0~0W0_0'  
         }  
         e l s e  
         {  
                 W r i t e L n   ' �0�0�0�0n0{v2�L0-NbkU0�0~0W0_0'  
         }  
 }  
 