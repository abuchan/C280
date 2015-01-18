import wx
import threading
import glob
import shared

class thermDisplay(threading.Thread):
    def __init__(self,q):
        threading.Thread.__init__(self)
        self.q = q
        
    def run(self):
        app = wx.App(False)
        frame = wx.Frame(None, -1, 'Thermal Camera')
        self.mf = mainPanel(frame,self.q)
        frame.Fit()
        frame.Show(True)
        app.MainLoop()
        
    def update(self, img, thm):
        self.mf.tp.update(img, thm)
    
class thermPanel(wx.Panel):
    def __init__(self, parent):
        wx.Panel.__init__(self, parent, size=(448,448))
        
        self.therm = [[0]*8]*8
        self.image = wx.EmptyBitmap(640, 480)
        
        self.SetBackgroundStyle(wx.BG_STYLE_CUSTOM)
        
        self.Bind(wx.EVT_PAINT, self.paint)
        
    def paint(self, event):
        dc = wx.AutoBufferedPaintDC(self)
        dc.Clear()
        
        dc.SetPen(wx.TRANSPARENT_PEN)
        
        i = 0
        for r in self.therm:
            j = 0
            for c in r:
                color = (255*c,255*(1.0-4*pow(0.5-c,2)),255*(1.0-c))
                dc.SetBrush(wx.Brush(wx.Color(color[0],color[1],color[2])))
                dc.DrawRectangle(j, i, 56, 56)
                j = j + 56
            i =  i + 56
        
        dc.DrawBitmap(self.image,-150,0)        
        
    def update(self, img, thm):
        i = wx.Image(img, wx.BITMAP_TYPE_PNG)
        i.SetAlphaData(chr(100)*640*480)
        self.image = wx.BitmapFromImage(i)
        self.therm = shared.scale_temp(thm,True,2800,3000)
        self.Refresh(False)
        
class mainPanel(wx.Panel):
    def __init__(self, parent,cq):
        wx.Panel.__init__(self, parent)
        
        self.cq = cq
        
        self.sizerV = wx.BoxSizer(wx.VERTICAL)
        
        self.tp = thermPanel(self)
        
        self.snap = wx.Button(self, label="Snap")
        self.Bind(wx.EVT_BUTTON, self.onClick, self.snap)
        
        self.label = wx.TextCtrl(self)
        
        self.sizerH = wx.BoxSizer(wx.HORIZONTAL)
        self.sizerH.Add(self.label,1,wx.GROW)
        self.sizerH.Add(self.snap,0,wx.GROW)
        
        self.sizerV.Add(self.tp,0,wx.GROW)
        self.sizerV.Add(self.sizerH,0,wx.GROW)
        
        self.SetSizer(self.sizerV)
        self.SetAutoLayout(1)
        self.sizerV.Fit(self)
    
    def onClick(self,event):
        if self.cq is not None:
            self.cq.put('c ' + self.label.GetValue())